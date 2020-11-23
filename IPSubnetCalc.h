//
//  IPSubnetCalc.h
//  SubnetCalc
//
//  Created by Julien Mulot on Tue May 06 2003.
//  Copyright (c) 2009 Julien Mulot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

#define DOT(x) ((8 * (x)) + ((x) - 1))

@interface IPSubnetCalc : NSObject {
    NSString		*networkClass;
    
    unsigned int	netId;
    unsigned int	netBits;
    unsigned int	mask;
    
    unsigned int	subnetMax;
    unsigned int	subnetBits;
    unsigned int	maskBits;
    unsigned int	subnetBitsMax;
    unsigned int	subnetMask;
    
    unsigned int	hostBits;
    unsigned int	hostMax;
    unsigned int	hostAddr;
    unsigned int	hostId;
    unsigned int	hostSubnetLbound;
    unsigned int	hostSubnetUbound;
    
    unsigned int	ciscoWildcard;
    char			bitMap[36];
    Boolean         classless;
}

@property Boolean   classless;

+ (NSString *)denumberize:(unsigned int)address;
+ (unsigned int)numberize:(const char *)address;
+ (int)countOnBits:(unsigned int)number;
- (void)initAddress:(const char *)address;
- (void)initAddressAndMask:(const char *)address mask:(unsigned int)addressMask;
- (void)initAddressAndMaskWithUnsignedInt:(unsigned int)address mask:(unsigned int)addressMask;
- (NSString *)subnetHostAddrRange;
- (NSString *)networkClass;
- (unsigned int)netBits;
- (NSString *)hexMap;
- (NSString *)binMap;
- (NSString *)bitMap;
- (void)setBitMap;
- (NSNumber *)hostAddr;
- (unsigned int)hostAddrIntValue;
- (NSNumber *)subnetBits;
- (NSNumber *)maskBits;
- (unsigned int)maskBitsIntValue;
- (NSNumber *)subnetMax;
- (NSNumber *)hostMax;
- (NSString *)subnetMask;
- (unsigned int)subnetMaskIntValue;
- (NSString *)subnetId;
- (NSString *)netId;
- (unsigned int)netIdIntValue;
- (NSString *)subnetBroadcast;
- (NSString *)supernetRoute:(int)supernetMaskBits;
- (NSString *)supernetAddrRange:(int)supernetMaskBits;

@end
