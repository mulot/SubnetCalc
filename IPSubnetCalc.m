//
//  IPSubnetCalc.m
//  SubnetCalc
//
//  Created by Julien Mulot on Tue May 06 2003.
//  Copyright (c) 2009 Julien Mulot. All rights reserved.
//

#import "IPSubnetCalc.h"


@implementation IPSubnetCalc

+ (unsigned int)numberize:(const char *)address
{
    unsigned int	sin_addr;
    
    if ((inet_pton(AF_INET, address, &sin_addr)) <= 0)
        return (-1);
    return (ntohl(sin_addr));
}

+ (NSString *)denumberize:(unsigned int)address
{
    char			*buffer;
    unsigned int	addr_nl;
	NSString		*nstr;
  
    addr_nl = htonl(address);
    if (!(buffer = malloc(INET_ADDRSTRLEN * sizeof (char))))
        return (NULL);
    if (!inet_ntop(AF_INET, &addr_nl, buffer, INET_ADDRSTRLEN * sizeof (char)))
        return (NULL);
	nstr = [NSString stringWithCString: buffer encoding: NSASCIIStringEncoding];
	free(buffer);
    return (nstr);
}

- (unsigned int)setBitsFromRight:(int)nbits
{
    int 		i;
    unsigned int	number = 0;
    
    for (i = 0; i < nbits; i++)
        number += (int) pow(2, i);
    return (number);
}

+ (int)countOnBits:(unsigned int)number
{
    unsigned int	mask_tmp = 1;
    int			i, on_bits;
    
    on_bits = 0;
    mask_tmp <<= 31;
    for (i = 0; i < 32; i++)
    {
        if (mask_tmp & number)
            on_bits++;
        number <<= 1;
    }
    return (on_bits);
}


- (IBAction)setBitMap
{
    int		i;
    int		dots = 0;
    char	bitcode = 'n';
    
    bitMap[DOT(1)] = '.';
    bitMap[DOT(2)] = '.';
    bitMap[DOT(3)] = '.';
    bitMap[35] = 0;
	
    for (i = 0; i < 35; i++)
    {
        if (i == DOT(1) || i == DOT(2) || i == DOT(3))
        {
            dots++;
            continue;
        }
        if (i == (netBits + dots))
            bitcode = 's';
        if (i == (netBits + subnetBits + dots))
            bitcode = 'h';
        bitMap[i] = bitcode;
    }
}

- (IBAction)initNetwork
{
    netId= mask & hostAddr;
    maskBits = netBits + subnetBits;
    hostBits = 32 - maskBits;
    hostMax = pow(2, hostBits) - 2;
    hostId = hostAddr - netId;
    subnetMask = ~(mask | [self setBitsFromRight:hostBits]);
    subnetMax = pow(2, subnetBits);
    subnetBitsMax = 32 - netBits;
    ciscoWildcard = ~(mask | subnetMask);
    hostSubnetLbound = (mask | subnetMask) & hostAddr;
    hostSubnetUbound = hostSubnetLbound + hostMax - 1;
    [self setBitMap];
}

- (IBAction)setMask:(unsigned int)val
{
    mask = val;
}

- (IBAction)setHostAddr:(unsigned int)val
{
    hostAddr = val;
}

- (int)incorrectSubnetBits
{
    return (subnetBits > (32 - netBits) ? 1 : 0);
}

- (char)getClass:(unsigned int)address
{
    unsigned int addr_val;
    
    addr_val = (address & 0xff000000) >> 24;
    
    if (addr_val < 127)
        return ('a');
    if (addr_val >= 127 && addr_val < 192)
        return ('b');
    if (addr_val >= 192 && addr_val < 224)
        return ('c');
    return ('d');
}

- (int)setClassInfo:(char)class defaults:(const int)setDefaults
{	
	if (networkClass)
		[networkClass release];
    switch (class)
    {
        case 'a' :
            networkClass = [[NSString alloc] initWithString: @"A"];
            netBits = 8;
            netId = 0x01000000; 
            mask = 0xff000000;
            break;
        case 'b' :
            networkClass = [[NSString alloc] initWithString: @"B"];
            netBits = 16;
            netId = 0x80000000; 
            mask = 0xffff0000;
            break;
        case 'c' :
            networkClass = [[NSString alloc] initWithString: @"C"];
            netBits = 24;
            netId = 0xc0000000; 
            mask = 0xffffff00;
            break;
		case 'd' :
			 networkClass = [[NSString alloc] initWithString: @"D"];
			 break;
        default :
            return (-1);
    }
	if (setDefaults)
        hostAddr = netId + 1;
    return (0);
}

- (void)initByAddr:(unsigned int)address
{
    char	class;
    
    class = [self getClass:address];
    subnetBits = 0;
    hostAddr = address;
    [self setClassInfo:class defaults:0];
    [self initNetwork];
}

- (void)initByAddrAndMask:(unsigned int)address mask:(unsigned int)addressMask
{
    char	class;
    
    class = [self getClass:address];
    hostAddr = address;
    [self setClassInfo:class defaults:0];
    if (mask > addressMask)
    {
        mask = addressMask;
        netBits = [IPSubnetCalc countOnBits:addressMask];
        subnetBits = 0;
    }
    else
    {
        subnetMask = mask^addressMask;
        subnetBits = [IPSubnetCalc countOnBits:subnetMask];
    }
    [self initNetwork];
}

- (void)initAddress:(const char *)address
{
    [self initByAddr:[IPSubnetCalc numberize:address]];
    
}

- (void)initAddressAndMask:(const char *)address mask:(unsigned int)addressMask
{
    [self initByAddrAndMask:[IPSubnetCalc numberize:address] mask:addressMask];
    
}

- (void)initAddressAndMaskWithUnsignedInt:(unsigned int)address mask:(unsigned int)addressMask
{
    [self initByAddrAndMask:address mask:addressMask];
    
}
- (NSString *)subnetHostAddrRange
{
    NSString		*strRange;
    unsigned int	tmpmask;
    
    strRange = [[[NSString alloc] initWithString: [IPSubnetCalc denumberize: ((hostAddr & (mask | subnetMask)) + 1)]] autorelease];
    tmpmask = -1;
    tmpmask >>= maskBits;
    return ([strRange stringByAppendingFormat: @" - %@", [IPSubnetCalc denumberize: ((hostAddr | tmpmask) - 1)]]);
}

- (NSString *)bitMap
{
	return ([NSString stringWithCString: bitMap encoding: NSASCIIStringEncoding]);
}

- (NSString *)binMap
{
    NSString		*str_binmap;
    unsigned int	address;
    unsigned int	mask_tmp = 1;
    int				i;

    str_binmap = [[[NSString alloc] init] autorelease];
    address = hostAddr;
    mask_tmp <<= 31;
    for (i = 0; i < 32; i++)
    {
        if (mask_tmp& address)
            str_binmap = [str_binmap stringByAppendingString: @"1"];
        else
            str_binmap = [str_binmap stringByAppendingString: @"0"];
		address <<= 1;
        if (i != 31 && ((i + 1) % 8 == 0))
            str_binmap = [str_binmap stringByAppendingString: @"."];
    }
    return (str_binmap);
}

- (NSString *)hexMap
{
    NSString		*str_hexmap;
    unsigned int	address;
    int				i;
        
    str_hexmap = [[[NSString alloc] init] autorelease];
    address = hostAddr;
    for (i = 0; i < 4; i++)
    {
        str_hexmap = [str_hexmap stringByAppendingFormat: @"%.2X", ((address << (8 * i)) >> 24)];
        if (i != 3)
			str_hexmap = [str_hexmap stringByAppendingString: @"."];
    }
    return (str_hexmap);
}

- (NSNumber *)subnetBits
{
    return ([NSNumber numberWithUnsignedInt: subnetBits]);
}

- (NSNumber *)maskBits
{
    return ([NSNumber numberWithUnsignedInt: maskBits]);
}

- (unsigned int)maskBitsIntValue
{
    return (maskBits);
}

- (NSNumber *)subnetMax
{
    return ([NSNumber numberWithUnsignedInt: subnetMax]);
}

- (NSNumber *)hostMax
{
    return ([NSNumber numberWithUnsignedInt: hostMax]);
}

- (NSString *)subnetId
{
    return ([IPSubnetCalc denumberize: (hostAddr & (mask | subnetMask))]);
}

- (NSString *)netId
{
    return ([IPSubnetCalc denumberize: (netId)]);
}

- (unsigned int)netIdIntValue
{
	return (netId);
}

- (NSString *)subnetMask
{
    return ([IPSubnetCalc denumberize: (mask | subnetMask)]);
}

- (unsigned int)subnetMaskIntValue
{
	return (mask | subnetMask);
}

- (NSString *)subnetBroadcast
{
    return ([IPSubnetCalc denumberize: (hostAddr & (mask | subnetMask)) | ~(mask | subnetMask)]);
}

- (NSNumber *)hostAddr
{
    return ([NSNumber numberWithUnsignedInt: hostAddr]);
}

- (unsigned int)hostAddrIntValue
{
    return (hostAddr);
}

- (NSString *)networkClass
{
    return (networkClass);
}

- (unsigned int)netBits
{
	return (netBits);
}

- (NSString *)supernetRoute:(int)supernetMaskBits
{
	unsigned int	tmpmask = -1;
    
	tmpmask <<= (32 - supernetMaskBits);
    return ([IPSubnetCalc denumberize: (hostAddr & tmpmask)]);
}

- (NSString *)supernetAddrRange:(int)supernetMaskBits
{
	NSString		*strRange;
    unsigned int	tmpmask = -1;
    
	tmpmask <<= (32 - supernetMaskBits);
    strRange = [[[NSString alloc] initWithString: [IPSubnetCalc denumberize: (hostAddr & tmpmask)]] autorelease];
    tmpmask = -1;
    tmpmask >>= supernetMaskBits;
    return ([strRange stringByAppendingFormat: @" - %@", [IPSubnetCalc denumberize: (hostAddr | tmpmask)]]);
}

@end
