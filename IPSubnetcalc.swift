//
//  IPSubnetcalc.swift
//  SubnetCalc
//
//  Created by Julien Mulot on 22/11/2020.
//

import Foundation
import Cocoa

//*********************
//Errors for IP format
//*********************
enum SubnetCalcError: Error {
    case invalidIPv4(_ info: String)
    case invalidIPv4Mask(_ info: String)
    case invalidIPv6(_ info: String)
    case invalidIPv6Mask(_ info: String)
}

class IPSubnetCalc: NSObject {
    //*********
    //Constants
    //*********
    enum Constants {
        //private constants
        static let NETWORK_BITS_MIN_CLASSLESS:Int = 1
        static let NETWORK_BITS_MIN:Int = 8
        static let NETWORK_BITS_MAX:Int = 32
        
        //IPv6 constants
        static let addr16Full: UInt16 = 0xFFFF
        static let addr16Empty: UInt16 = 0x0000
        static let defaultIPv6to4Mask: Int = 96
        //static let addr128Full: [UInt16] = [addr16Full, addr16Full, addr16Full, addr16Full, addr16Full, addr16Full, addr16Full, addr16Full]
        //static let addr128Empty: [UInt16] = [addr16Empty, addr16Empty, addr16Empty, addr16Empty, addr16Empty, addr16Empty, addr16Empty, addr16Empty]
        //static let addr16Hex1: UInt16 = 0xF000
        //static let addr16Hex2: UInt16 = 0x0F00
        //static let addr16Hex3: UInt16 = 0x00F0
        //static let addr16Hex4: UInt16 = 0x000F
        static let resIPv6Blocks: [String : String] = ["::1/128" : "Loopback Address",
                                                       "::/128" : " Unspecified Address",
                                                       "::ffff:0:0/96" : "IPv4-mapped Address",
                                                       "64:ff9b::/96" : "IPv4-IPv6 Translation",
                                                       "64:ff9b:1::/48" : "IPv4-IPv6 Translation",
                                                       "100::/64" : "Discard-Only Address Block",
                                                       "2001::/23" : "IETF Protocol Assignments",
                                                       "2001::/32" : "TEREDO",
                                                       "2001:1::1/128" : "Port Control Protocol Anycast",
                                                       "2001:1::2/128" : "Traversal Using Relays around NAT Anycast",
                                                       "2001:2::/48" : "Benchmarking",
                                                       "2001:3::/32" : "AMT",
                                                       "2001:4:112::/48" : "AS112-v6",
                                                       "2001:10::/28" : "Deprecated (previously ORCHID)",
                                                       "2001:20::/28" : "ORCHIDv2",
                                                       "2001:db8::/32" : "Documentation",
                                                       "2002::/16" : "6to4",
                                                       "2620:4f:8000::/48" : "Direct Delegation AS112 Service",
                                                       "fc00::/7" : "Unique-Local",
                                                       "fe80::/10" : "Link-Local Unicast"
        ]
        
        //IPv4 constants
        static let classAbits: Int = 8
        static let classBbits: Int = 16
        static let classCbits: Int = 24
        static let addr32Full: UInt32 = 0xFFFFFFFF
        static let addr32Empty: UInt32 = 0x00000000
        static let addr32Digit1: UInt32 = 0xFF000000
        static let addr32Digit2: UInt32 = 0x00FF0000
        static let addr32Digit3: UInt32 = 0x0000FF00
        static let addr32Digit4: UInt32 = 0x000000FF
        static let netIdClassA: UInt32 = 0x01000000
        static let maskClassA: UInt32 = 0xFF000000
        static let netIdClassB: UInt32 = 0x80000000
        static let maskClassB: UInt32 = 0xFFFF0000
        static let netIdClassC: UInt32 = 0xC0000000
        static let maskClassC: UInt32 = 0xFFFFFF00
        static let netIdClassD: UInt32 = 0xE0000000
        static let maskClassD: UInt32 = 0xF0000000
        static let netIdClassE: UInt32 = 0xF0000000
        static let maskClassE: UInt32 = 0xF0000000
    }
    
    //****************
    //Class Properties
    //****************
    var ipv4Address: String
    var maskBits: Int
    var ipv6Address: String
    var ipv6MaskBits: Int
    
    
    //*************
    //IPv4 SECTION
    //*************
    /**
     Convert an IP address in its binary representation
     
     - Parameters:
        - ipAddress: IP address in dotted decimal format like 192.168.1.42
        - space:  add a space to each decimal
        - dotted: add a dot to each decimal
     
     - Returns:
     the binary representation of the given IP address
     
     */
    static func binarize(ipAddress: String, space: Bool = false, dotted: Bool = true) -> String? {
        var ipAddressBin = [String]()
        var binStr = String()
        var ipDigits = [String]()
        
        ipDigits = ipAddress.components(separatedBy: ".")
        
        if ipDigits.count != 4 {
            return nil
        }
        for index in 0...3 {
            if let ipDigit = Int(ipDigits[index]) {
                ipAddressBin.append(String(ipDigit, radix: 2))
            }
            else {
                return nil
            }
            while (ipAddressBin[index].count < 8) {
                ipAddressBin[index].insert("0", at: ipAddressBin[index].startIndex)
            }
            
            var digitBin = ipAddressBin[index]
            if (space == true) {
                digitBin.insert(" ", at: ipAddressBin[index].index(ipAddressBin[index].startIndex, offsetBy: 4))
            }
            if (index < 3) {
                if (dotted == true) {
                    binStr += digitBin + "."
                }
                else {
                    binStr += digitBin
                }
            }
            else {
                binStr += digitBin
            }
        }
        return (binStr)
    }
    
    /**
     Convert the current IPv4 address to its binary representation
     
     - Parameter dotted: add dot to each decimal
     
     - Returns:
     the binary representation of the current IP address
     
     */
    func binaryMap(dotted: Bool = true) -> String {
        return (IPSubnetCalc.binarize(ipAddress: ipv4Address, space: false, dotted: dotted)!)
    }
    
    /**
     Convert an IP address in its hexadecimal representation
     
     - Parameters:
        - ipAddress: IP address in dotted decimal format like 192.168.1.42
        - dotted: add a dot to each decimal
     
     - Returns:
     the hexadecimal representation of the given IP address
     
     */
    static func hexarize(ipAddress: String, dotted: Bool = true) -> String? {
        var ipDigits = [String]()
        var hexIP = String()
        var hex4: String
        
        ipDigits = ipAddress.components(separatedBy: ".")
        if ipDigits.count != 4 {
            return nil
        }
        for index in 0...3 {
            if let ipDigit = Int(ipDigits[index]) {
            hex4 = String(format: "%X", ipDigit)
            }
            else {
                return nil
            }
            if (hex4.count == 1) {
                hex4 = "0" + hex4
            }
            hexIP += hex4
            if (index < 3) {
                if (dotted == true) {
                    hexIP += "."
                }
            }
        }
        return (hexIP)
    }
    
    /**
     Convert the current IPv4 address to its hexadecimal representation
     
     - Parameter dotted: add dot to each decimal
     
     - Returns:
     the hexadecimal representation of the current IP address
     
     */
    func hexaMap(dotted: Bool = true) -> String {
        return (IPSubnetCalc.hexarize(ipAddress: ipv4Address, dotted: dotted)!)
    }
    
    /**
     Convert an IP address in dotted decimal format to an UInt32 value
     
     - Parameter ipAddress: an IP address in dotted decimal format like 192.168.1.42
     
     - Returns:
     a digital IP address in UInt32 format
     
     */
    static func digitize(ipAddress: String) -> UInt32? {
        var ipAddressNum: UInt32 = 0
        var ipDigits = [String]()
        //var ipDigit: Unit32
        
        ipDigits = ipAddress.components(separatedBy: ".")
        if ipDigits.count != 4 {
            return nil
        }
        for index in 0...3 {
            if let ipDigit = UInt32(ipDigits[index]) {
                ipAddressNum += ipDigit << (32 - 8 * (index + 1))
            }
            else {
                return nil
            }
        }
        return (ipAddressNum & Constants.addr32Full)
    }
    
    //OLD numerize a String as a Mask bits value to UInt32
    /*
     static func numerize(maskDigit: String) -> UInt32 {
     var maskNum: UInt32 = 0
     
     if (Int(maskDigit) != nil) {
     maskNum = (Constants.addr32Full << (32 - Int(maskDigit)!)) & Constants.addr32Full
     }
     return (maskNum)
     }
     */
    
    /**
     Convert a mask value in bits to an UInt32 value
     
     - Parameter maskbits: subnet mask bits as in /XX notation
     
     - Returns:
     a digital subnet mask in UInt32 format

     */
    static func digitize(maskbits: Int) -> UInt32? {
        if (maskbits <= Constants.NETWORK_BITS_MAX && maskbits >= Constants.NETWORK_BITS_MIN_CLASSLESS) {
            return ((Constants.addr32Full << (32 - maskbits)) & Constants.addr32Full)
        }
        return nil
    }
    
    /**
     Convert an IP address in digital format to dotted decimal format
     
     - Parameter ipAddress: IP address in its digital format
     
     - Returns:
     a String reprensenting the dotted decimal format of the given IP address
     
     */
    static func dottedDecimal(ipAddress: UInt32) -> String {
        var ipDigits = String()
        
        ipDigits.append(String(((ipAddress & Constants.addr32Digit1) >> Constants.classCbits)) + ".")
        ipDigits.append(String(((ipAddress & Constants.addr32Digit2) >> Constants.classBbits)) + ".")
        ipDigits.append(String(((ipAddress & Constants.addr32Digit3) >> Constants.classAbits)) + ".")
        ipDigits.append(String(((ipAddress & Constants.addr32Digit4))))
        return (ipDigits)
    }
    
    /**
     Check if the IP address is a valid IPv4 address
     
     - Parameters:
        - ipAddress: IP address in dotted decimal format like 192.168.1.42
        - mask: Optionnal subnet mask
        - classless: enable class less checks of the given IP address/mask
     
     - Throws: an invalid IP or invalid mask error with a message explaining the reason
     
     */
    static func validateIPv4(ipAddress: String, mask: String?, classless: Bool = false) throws {
        var ip4Digits = [String]()
        
        ip4Digits = ipAddress.components(separatedBy: ".")
        if (ip4Digits.count == 4) {
            for item in ip4Digits {
                if let digit = Int(item, radix: 10) {
                    if (digit > 255) {
                        print("bad IPv4 digit \(digit)")
                        throw SubnetCalcError.invalidIPv4("IPv4 digit \(digit) is greater than 255")
                        //return false
                    }
                }
                else {
                    print("not digit: \(item)")
                    throw SubnetCalcError.invalidIPv4("not digit: \(item)")
                    //return false
                }
            }
        }
        else {
            print("bad IPv4 format \(ip4Digits)")
            throw SubnetCalcError.invalidIPv4("\(ipAddress) too short or too long")
            //return false
        }
        if mask != nil {
            if let maskNum = Int(mask!) {
                if (classless == true) {
                    if (maskNum < Constants.NETWORK_BITS_MIN_CLASSLESS || maskNum > Constants.NETWORK_BITS_MAX) {
                        print("IPv4 classless mask \(maskNum) invalid")
                        throw SubnetCalcError.invalidIPv4Mask("IPv4 classless mask \(maskNum) should be between \(Constants.NETWORK_BITS_MIN_CLASSLESS) and \(Constants.NETWORK_BITS_MAX)")
                        //return false
                    }
                }
                else if (maskNum < Constants.NETWORK_BITS_MIN || maskNum > Constants.NETWORK_BITS_MAX) {
                    print("IPv4 mask \(maskNum) invalid")
                    throw SubnetCalcError.invalidIPv4Mask("IPv4 mask \(maskNum) should be between \(Constants.NETWORK_BITS_MIN) and \(Constants.NETWORK_BITS_MAX)")
                    //return false
                }
            }
            else {
                print("IPv4 mask \(mask!) is not digit")
                throw SubnetCalcError.invalidIPv4Mask("IPv4 mask \(mask!) is not a digit")
                //return false
            }
        }
        else {
            //print("null mask")
        }
        //return true
    }
    
    /**
     Returns current Subnet ID address
     
     - Returns:
     the dotted decimal representation of the Subnet ID of the current IP address/mask
     
     */
    func subnetId() -> String {
        var subnetId: UInt32 = 0
        let ipBits = IPSubnetCalc.digitize(ipAddress: self.ipv4Address)!
        let maskBits = IPSubnetCalc.digitize(maskbits: self.maskBits)!
        
        subnetId = ipBits & maskBits
        return (IPSubnetCalc.dottedDecimal(ipAddress: subnetId))
    }
    
    /**
     Returns current broadcast address
     
     - Returns:
     the dotted decimal representation of the broadcast address of the current IP address/mask
     
     */
    func subnetBroadcast() -> String {
        var broadcast: UInt32 = 0
        let ipBits = IPSubnetCalc.digitize(ipAddress: self.ipv4Address)!
        let maskBits = IPSubnetCalc.digitize(maskbits: self.maskBits)!
        
        broadcast = ipBits & maskBits | (Constants.addr32Full >> self.maskBits)
        return (IPSubnetCalc.dottedDecimal(ipAddress: broadcast))
    }
    
    /**
     Returns current Subnet Mask
     
     - Returns:
    String of the current subnet mask as in /XX notation
     
     */
    func subnetMask() -> String {
        var subnetMask: UInt32 = 0
        
        subnetMask = Constants.addr32Full << (32 - self.maskBits)
        return (IPSubnetCalc.dottedDecimal(ipAddress: subnetMask))
    }
    
    /**
     Returns current Wildcard Subnet Mask
     
     - Returns:
     the dotted decimal representation of the wildcard subnet mask of the current IP address/mask
     
     */
    func wildcardMask() -> String {
        var wildcardMask: UInt32 = 0
        
        wildcardMask = ~(Constants.addr32Full << (32 - self.maskBits))
        return (IPSubnetCalc.dottedDecimal(ipAddress: wildcardMask))
    }
    
    /**
     Returns the maximum hosts in the current subnet
     
     - Returns:
     maximum hosts for the current mask
     
     */
    func maxHosts() -> Int {
        var maxHosts: UInt32 = 0
        
        if (self.maskBits == 32) {
            return (0)
        }
        maxHosts = (Constants.addr32Full >> self.maskBits) - 1
        return (Int(maxHosts))
    }
    
    /**
     Returns the maximum CIDR subnets
     
     - Returns:
     maximum CIDR subnets for the current mask
     
     */
    func maxCIDRSubnets() -> Int {
        var max: Int = 0
        
        max = Int(truncating: NSDecimalNumber(decimal: pow(2, (32 - self.maskBits))))
        //max = Int(truncating: pow(2, (32 - self.maskBits)) as NSDecimalNumber)
        return (max)
    }
    
    /**
     Returns the maximum CIDR Supernets
     
     - Returns:
     maximum CIDR Supernets for the current mask
     
     */
    func maxCIDRSupernet() -> Int {
        let classType = self.netClass()
        var result: Decimal
        
        if (classType == "A") {
            if (Constants.classAbits - self.maskBits > 0) {
                result = pow(2, Constants.classAbits - self.maskBits)
                return (Int(truncating: NSDecimalNumber(decimal: result)))
            }
        }
        else if (classType == "B") {
            if (Constants.classBbits - self.maskBits > 0) {
                result = pow(2, Constants.classBbits - self.maskBits)
                return (Int(truncating: NSDecimalNumber(decimal: result)))
            }
        }
        else if (classType == "C") {
            if (Constants.classCbits - self.maskBits > 0) {
                result = pow(2, Constants.classCbits - self.maskBits)
                return (Int(truncating: NSDecimalNumber(decimal: result)))
            }
        }
        return (1)
    }
    
    /**
     Returns the current subnet IP Range
     
     - Returns:
     First IP address - Last IP address of the current IP address/mask
     
     */
    func subnetRange() -> String {
        var range = String()
        var firstIP: UInt32 = 0
        var lastIP: UInt32 = 0
        
        if (maskBits == 31 || maskBits == 32) {
            firstIP = IPSubnetCalc.digitize(ipAddress: subnetId())!
            lastIP = IPSubnetCalc.digitize(ipAddress: subnetBroadcast())!
        }
        else {
            firstIP = IPSubnetCalc.digitize(ipAddress: subnetId())! + 1
            lastIP = IPSubnetCalc.digitize(ipAddress: subnetBroadcast())! - 1
        }
        range = IPSubnetCalc.dottedDecimal(ipAddress: firstIP) + " - " + IPSubnetCalc.dottedDecimal(ipAddress: lastIP)
        return (range)
    }
    
    /**
     Returns the current CIDR subnet IP Range
     
     - Returns:
     First IP address - Last IP address of the current CIDR IP address/mask
     
     */
    func subnetCIDRRange() -> String {
        var range = String()
        var firstIP: UInt32 = 0
        var lastIP: UInt32 = 0
        
        firstIP = IPSubnetCalc.digitize(ipAddress: subnetId())!
        lastIP = IPSubnetCalc.digitize(ipAddress: subnetBroadcast())!
        range = IPSubnetCalc.dottedDecimal(ipAddress: firstIP) + " - " + IPSubnetCalc.dottedDecimal(ipAddress: lastIP)
        return (range)
    }
    
    /**
     Returns the Network Class of an IP address
     
     - Parameter ipAddress: IPv4 address in dotted decimal format
     
     - Returns:
     Network Class conforming to RFC 790
     
     */
    static func netClass(ipAddress: String) -> String? {
        if let ipNum = IPSubnetCalc.digitize(ipAddress: ipAddress) {
        let addr1stByte = (ipNum & Constants.maskClassA) >> 24
        
        if (addr1stByte < 127) {
            return ("A")
        }
        if (addr1stByte >= 127 && addr1stByte < 192) {
            return ("B")
        }
        if (addr1stByte >= 192 && addr1stByte < 224) {
            return ("C")
        }
        if (addr1stByte >= 224 && addr1stByte < 240) {
            return ("D")
        }
        return ("E")
        }
        return nil
    }
    
    /**
     Returns the Network Class of the current IP address
     
     - Returns:
     Network Class of the current IP address conforming to RFC 790
     
     */
    func netClass() -> String {
        return (IPSubnetCalc.netClass(ipAddress: ipv4Address)!)
    }
    
    /**
     Returns the bits dedicated to the Subnet part of the IP Address
     
     - Returns:
     bits dedicated to the Subnet part of the current IP Address
     
     */
    func subnetBits() -> Int {
        let classType = self.netClass()
        var bits: Int = 0
        
        if (classType == "A") {
            if (self.maskBits > Constants.classAbits) {
                bits = self.maskBits - Constants.classAbits
            }
        }
        else if (classType == "B") {
            if (self.maskBits > Constants.classBbits) {
                bits = self.maskBits - Constants.classBbits
            }
        }
        else if (classType == "C") {
            if (self.maskBits > Constants.classCbits) {
                bits = self.maskBits - Constants.classCbits
            }
        }
        return (bits)
    }
    
    /**
     Returns the bits dedicated to Network Class
     
     - Returns:
     bits dedicated to the Network Class of the current IP address
     
     */
    func classBits() -> Int {
        let classType = self.netClass()
        
        if (classType == "A") {
            return (Constants.classAbits)
        }
        else if (classType == "B") {
            return (Constants.classBbits)
        }
        else if (classType == "C") {
            return (Constants.classCbits)
        }
        return (32)
    }
    
    /**
     Returns the mask bits for the Network Class
     
     - Returns:
     mask bits dedicated for the Network Class of the current IP address
     
     */
    func classMask() -> UInt32 {
        let classType = self.netClass()
        
        if (classType == "A") {
            return (Constants.maskClassA)
        }
        else if (classType == "B") {
            return (Constants.maskClassB)
        }
        else if (classType == "C") {
            return (Constants.maskClassC)
        }
        else if (classType == "D") {
            return (Constants.maskClassD)
        }
        else if (classType == "E") {
            return (Constants.maskClassE)
        }
        return (Constants.maskClassE)
    }
    
    /**
     Returns the number of bits of the mask
     
     - Parameter maskAddr: mask in dotted decimal format
     
     - Returns:
     the number of bits for the given mask
     
     */
    static func maskBits(maskAddr: String) -> Int? {
        var bits: Int = 0
        
        if var mask:UInt32 = IPSubnetCalc.digitize(ipAddress: maskAddr) {
        while (mask != 0) {
            bits += 1
            mask <<= 1
        }
        //print("maskBits \(maskAddr) bits: \(bits)")
        return (bits)
        }
        return nil
    }
    
    /**
     Returns the number of bits of the mask
     
     - Parameter mask: mask in digitize format
     
     - Returns:
     the number of bits for the given mask
     
     */
    static func maskBits(mask: UInt32) -> Int {
        var bits: Int = 0
        var tmpmask = mask
        
        while (tmpmask != 0) {
            bits += 1
            tmpmask <<= 1
        }
        //print("maskBits \(mask) bits: \(bits)")
        return (bits)
    }
    
    /**
     Returns the number of bits dedicated to Network
     
     - Returns:
     number of bits dedicated to the Network of the current IP address
     
     */
    func netBits() -> Int {
        let classType = self.netClass()
        var bits: Int = 0
        
        if (classType == "A") {
            if (self.maskBits > Constants.classAbits) {
                bits =  Constants.classAbits
            }
            else {
                bits = self.maskBits
            }
        }
        else if (classType == "B") {
            if (self.maskBits > Constants.classBbits) {
                bits = Constants.classBbits
            }
            else {
                bits = self.maskBits
            }
        }
        else if (classType == "C") {
            if (self.maskBits > Constants.classCbits) {
                bits = Constants.classCbits
            }
            else {
                bits = self.maskBits
            }
        }
        return (bits)
    }
    
    /**
     Returns the maximum number of subnets
     
     - Returns:
     maximum number of subnets for the current Subnet bits
     
     */
    func maxSubnets() -> Int {
        var maxSubnets: Int = 0
        
        let bits = subnetBits()
        maxSubnets = Int(truncating: NSDecimalNumber(decimal: pow(2, bits)))
        return (maxSubnets)
    }
    
    /**
     Returns the Bit Map representation
     
     - Parameter dotted: add dot at each decimal
     
     - Returns:
     Bit Map reprensenation of the current ip address/mask
     
     */
    func bitMap(dotted: Bool = true) -> String {
        let netBits = self.netBits()
        let subnetBits = self.subnetBits()
        var bitMap = String()
        
        for index in 0...31 {
            if (index < netBits) {
                bitMap.append("n")
            }
            else if (index < (netBits + subnetBits)) {
                bitMap.append("s")
            }
            else {
                bitMap.append("h")
            }
            if ((index < 31) && ((index + 1) % 8 == 0)) {
                if (dotted == true) {
                    bitMap.append(".")
                }
            }
        }
        return (bitMap)
    }
    
    /**
     Returns maskbits and number of max hosts for a requested number of hosts
     
     - Parameter hosts: number of requested hosts
     
     - Returns: maskbits and number of max hosts for the requested number of hosts
        
     */
    static func fittingSubnet(hosts: UInt) -> (Int, UInt) {
        var maxHosts: UInt
        
        for index in 1...31 {
            maxHosts = UInt(truncating: NSDecimalNumber(decimal: pow(2, index))) - 2
            if (hosts <= maxHosts) {
                return (32 - index, maxHosts)
            }
        }
        return (0, 0)
    }
    
    /**
     Display IP informations of the current IP address/mask
     */
    func displayIPInfo() {
        print("IP Host : " + self.ipv4Address)
        print("Mask bits : \(self.maskBits)")
        print("Mask : " + self.subnetMask())
        print("Subnet bits : \(self.subnetBits())")
        print("Subnet ID : " + self.subnetId())
        print("Broadcast : " + self.subnetBroadcast())
        print("Max Host : \(self.maxHosts())")
        print("Max Subnet : \(self.maxSubnets())")
        print("Subnet Range : " + self.subnetRange())
        print("IP Class Type : " + self.netClass())
        print("Hexa IP : " + self.hexaMap())
        print("Binary IP : " + self.binaryMap())
        print("BitMap : " + self.bitMap())
        print("CIDR Netmask : " + self.subnetMask())
        print("Wildcard Mask : " + self.wildcardMask())
        print("CIDR Max Subnet : \(self.maxCIDRSubnets())")
        print("CIDR Max Hosts : \(self.maxHosts())")
        print("CIDR Network (Route) : " + self.subnetId())
        print("CIDR Net Notation : " + self.subnetId() + "/" + String(self.maskBits))
        print("CIDR Address Range : " + self.subnetCIDRRange())
        print("IP number in binary : " + String(IPSubnetCalc.digitize(ipAddress: self.ipv4Address)!, radix: 2))
        print("Mask bin : " + String(IPSubnetCalc.digitize(maskbits: self.maskBits)!, radix: 2))
        //print("Subnet ID bin : " + String(self.subnetId(), radix: 2))
        //print("Broadcast bin : " + String(self.subnetBroadcast(), radix: 2))
    }
    
    //*************
    //IPv6 SECTION
    //*************
    /**
     Check if the IP address is a valid IPv6 address
     
     - Parameters:
        - ipAddress: IPv6 address in hexadecimal format
        - mask: Optionnal subnet mask
     
     - Returns:
     Boolean if the given IPv6 address is valid or not
     
     */
    static func validateIPv6(ipAddress: String, mask: Int?) throws {
        var ip4Hex: [String]?
        var hex: UInt16?
        
        if mask != nil {
            if (mask! < 1 || mask! > 128) {
                print("mask \(mask!) invalid")
                throw SubnetCalcError.invalidIPv6Mask("mask \(mask!) must be between 1 and 128")
            }
        }
        else {
            //print("null mask")
        }
        
        ip4Hex = ipAddress.components(separatedBy: ":")
        if (ip4Hex == nil) {
            //print("\(ipAddress) invalid")
            throw SubnetCalcError.invalidIPv6("IPv6 address must contain :")
        }
        if (ip4Hex!.count != 8) {
            //print("no 8 hex")
            if (ipAddress.contains("::"))
            {
                if (ipAddress.components(separatedBy: "::").count > 2) {
                    //print("too many '::'")
                    throw SubnetCalcError.invalidIPv6("too many ::")
                }
            }
            else {
                //print("IPv6 \(ipAddress) bad format")
                throw SubnetCalcError.invalidIPv6("short IPv6 address must contain ::")
            }
        }
        for index in 0...(ip4Hex!.count - 1) {
            //print("Index : \(index) IPHex : \(ip4Hex[index]) Dec : \(String(UInt16(ip4Hex[index], radix: 16)!, radix: 16))")
            if (ip4Hex![index].count > 4 && ip4Hex![index].count != 0) {
                //print("\(ip4Hex![index]) too large")
                throw SubnetCalcError.invalidIPv6("\(ip4Hex![index]) segment is too large")
            }
            hex = UInt16(ip4Hex![index], radix: 16)
            if hex != nil {
                if (hex! < 0 || hex! > 0xFFFF) {
                    //print("\(hex!) is invalid")
                    throw SubnetCalcError.invalidIPv6("\(hex!) segment must be between 0 and 0xFFFF")
                }
            }
            else {
                if (ip4Hex![index] != "") {
                    //print("\(ip4Hex![index]) not an integer")
                    throw SubnetCalcError.invalidIPv6("\(ip4Hex![index]) segment is not an integer")
                }
            }
        }
        //return true
    }
    
    /**
     Convert an IPv4 address to its IPv6 address
     
     - Parameters:
        - ipAddress: IPv4 address in dotted decimal format
        - _6to4: Use 6to4 representation
     
     - Returns:
     translated IPv6 address
     
     */
    static func convertIPv4toIPv6(ipAddress: String, _6to4: Bool = false) -> String {
        var ipv6str = String()
        
        if let addr = digitize(ipAddress: ipAddress) {
        ipv6str.append(String((((Constants.addr32Digit1 | Constants.addr32Digit2) & addr) >> 16), radix: 16))
        ipv6str.append(":")
        ipv6str.append(String(((Constants.addr32Digit3 | Constants.addr32Digit4) & addr), radix: 16))
        if (_6to4)
        {
            return ("2002:" + ipv6str + ":0:0:0:0:0")
        }
        return ("0:0:0:0:0:ffff:" + ipv6str)
        }
        else {
            return ""
        }
    }
    
    /**
     Convert an IPv6 address to its IPv4 address
     
     - Parameter ipAddress: IPv6 address in hexadecimal format
     
     - Returns:
     translated IPv4 address and detected translation method (6to4 or IPv4-Mapped)
     
     */
    static func convertIPv6toIPv4(ipAddress: String) -> (String, String) {
        var ipv4str = String()
        //let ip4Hex = fullAddressIPv6(ipAddress: ipAddress).components(separatedBy: ":")
        let ip4Hex = ipAddress.components(separatedBy: ":")
        let index = ip4Hex.count
        if (ip4Hex[0] == "2002") {
            if (index > 2) {
                if (ip4Hex[1] == "") {
                    ipv4str.append("0.0")
                }
                else {
                    ipv4str.append(String((UInt32(ip4Hex[1], radix: 16)! & Constants.addr32Digit3) >> 8))
                    ipv4str.append("." + String((UInt32(ip4Hex[1], radix: 16)! & Constants.addr32Digit4)))
                }
                if (ip4Hex[2] == "") {
                    ipv4str.append(".0.0")
                }
                else {
                    ipv4str.append("." + String((UInt32(ip4Hex[2], radix: 16)! & Constants.addr32Digit3) >> 8))
                    ipv4str.append("." + String((UInt32(ip4Hex[2], radix: 16)! & Constants.addr32Digit4)))
                }
            }
            return (ipv4str, "6to4")
        }
        else {
            if (index < 2) {
                ipv4str.append("0.0")
            }
            else {
                if (ip4Hex[index - 2] == "") {
                    ipv4str.append("0.0")
                }
                else {
                    ipv4str.append(String((UInt32(ip4Hex[index - 2], radix: 16)! & Constants.addr32Digit3) >> 8))
                    ipv4str.append("." + String((UInt32(ip4Hex[index - 2], radix: 16)! & Constants.addr32Digit4)))
                }
            }
            if (ip4Hex[index - 1] == "") {
                ipv4str.append(".0.0")
            }
            else {
                ipv4str.append("." + String((UInt32(ip4Hex[index - 1], radix: 16)! & Constants.addr32Digit3) >> 8))
                ipv4str.append("." + String((UInt32(ip4Hex[index - 1], radix: 16)! & Constants.addr32Digit4)))
            }
            return (ipv4str, "IPv4-Mapped")
        }
    }
    
    /**
     Convert an IPv6 address in hexadecimal format to its digital format
     
     - Parameter ipAddress: an IPv6 address in hexadecimal format. Must be in full format.
     
     - Returns:
     UInt16 array of each digitized IPv6 address hexa segments
     
     */
    static func digitizeIPv6(ipAddress: String) -> [UInt16] {
        var ipAddressNum: [UInt16] = Array(repeating: 0, count: 8)
        var ip4Hex = [String]()
        
        ip4Hex = IPSubnetCalc.fullAddressIPv6(ipAddress: ipAddress).components(separatedBy: ":")
        for index in 0...(ip4Hex.count - 1) {
            if (ip4Hex[index] == "") {
                ip4Hex[index] = "0"
            }
            ipAddressNum[index] = UInt16(ip4Hex[index], radix: 16)!
            //print("Index: \(index) Ip4Hex: \(ip4Hex[index]) Hexa : \(UInt16(ip4Hex[index], radix: 16)!)")
        }
        return (ipAddressNum)
    }
    
    /**
     Convert an IPv6 address in its binary representation
     
     - Parameters:
        - ipAddress: IPv6 address in hexadecimal format
        - delimiter: add ':' to each hexa segment
     
     - Returns:
     the binary representation of the given IPv6 address
     */
    static func binarizeIPv6(ipAddress: String, delimiter: Bool = false) -> String {
        var ip4Hex: [String]
        var binary: String
        var binStr = String()
        
        ip4Hex = ipAddress.components(separatedBy: ":")
        for index in 0...7 {
            binary = String(UInt16(ip4Hex[index], radix: 16)!, radix: 2)
            while (binary.count < 16) {
                binary.insert("0", at: binary.startIndex)
            }
            binStr.append(binary)
            if (delimiter && index < 7) {
                binStr.append(":")
            }
            //print("Index: \(index) Ip4Hex: \(ip4Hex[index]) Bin : \(binary)")
        }
        return (binStr)
    }
    
    /**
     Convert an IPv6 mask value in bits to its digitized UInt16 array value
     
     - Parameter maskbits: subnet mask bits as in /XX notation
     
     - Returns:
     a digital subnet mask in [UInt16] format
     
     */
    static func digitizeMaskIPv6(maskbits: Int) -> [UInt16] {
        var maskNum: [UInt16] = Array(repeating: 0, count: 8)
        
        for i in 0...7 {
            //print("Index : \(i), mask bits : \(maskbits - (16 * (i + 1)) >= 0 ? 16 : (maskbits % (16 * i)) < maskbits ? (maskbits % (16 * i)) : 0) Div : \(maskbits / (16 * (i + 1))) Mod : \(maskbits % (16 * (i + 1)))")
            if ((maskbits - (16 * i)) < 16) {
                if ((maskbits - (16 * i)) > 0) {
                    maskNum[i] = UInt16(Constants.addr16Full & (Constants.addr16Full << (16 - (maskbits - (16 * i)))))
                }
                else {
                    //print("Index : \(i), ZERO mask  : \(maskNum[i])")
                }
            }
            else {
                maskNum[i] = Constants.addr16Full
            }
        }
        return (maskNum)
    }
    
    /**
     Convert a digitized IPv6 address in its hexadecimal representation
     
     - Parameters:
        - num: IPv6 address in its digitized format
        - full: return a full representation (non compact) of the IPv6 address
        - column: add ':' at each hexa segment
     
     - Returns:
     the hexadecimal representation of the given IPv6 address
     
     */
    static func hexarizeIPv6(num: [UInt16], full: Bool = true, column: Bool = false) -> String {
        var hex: String
        var hexStr = String()
        
        for index in 0...(num.count - 1) {
            hex = String(num[index], radix: 16)
            while (hex.count < 4 && full) {
                hex.insert("0", at: hex.startIndex)
            }
            hexStr.append(hex)
            if (column && index < (num.count - 1)) {
                hexStr.append(":")
            }
        }
        return (hexStr)
    }
    
    /**
     Returns the Hexadecimal ID of IPv6 address
     
     - Returns:
     the hexadecimal ID of the current IPv6 address
     
     */
    func hexaIDIPv6() -> String {
        var hexID: String = IPSubnetCalc.fullAddressIPv6(ipAddress: self.ipv6Address)
        let delimiter: Set<Character> = [":"]
        hexID.removeAll(where: { delimiter.contains($0) })
        return("0x\(hexID)")
    }
    
    /**
     Returns the binary representation of IPv6 address
     
     - Returns:
     the binary representation of the current IPv6 address
     
     */
    func binaryIDIPv6() -> String {
        return (IPSubnetCalc.binarizeIPv6(ipAddress: self.ipv6Address))
    }
    
    /**
     Convert a IPv6 address to its long notation
     
     - Parameter ipAddress: IPv6 address in hexadecimal format

     - Returns:
     the long notation (non compact) of the given IPv6 address
     
     */
    static func fullAddressIPv6(ipAddress: String) -> String {
        var fullAddr = String()
        var ip4Hex = [String]()
        var prevIsZero = false
        
        ip4Hex = ipAddress.components(separatedBy: ":")
        for index in 0...(ip4Hex.count - 1) {
            //print("Index : \(index) Hex :  \(ip4Hex[index])")
            if (ip4Hex[index] == "" && !prevIsZero) {
                prevIsZero = true
                //print("Index : \(index + 1) is empty, \(8 - ip4Hex.count  + 1) hex quad are missing")
                while (ip4Hex[index].count < (4 * (8 - ip4Hex.count  + 1))) {
                    ip4Hex[index].insert("0", at: ip4Hex[index].startIndex)
                }
            }
            else {
                while (ip4Hex[index].count < 4) {
                    ip4Hex[index].insert("0", at: ip4Hex[index].startIndex)
                }
            }
            fullAddr.append(ip4Hex[index])
        }
        var offset = fullAddr.index(fullAddr.startIndex, offsetBy: 4)
        for _ in 1...7 {
            fullAddr.insert(":", at: offset)
            offset = fullAddr.index(offset, offsetBy: 5)
        }
        return (fullAddr)
    }
    
    /**
     Convert a IPv6 address to its compact/short notation
     
     - Parameter ipAddress: IPv6 address in hexadecimal format
     
     - Returns:
     the compact notation of the given IPv6 address
     
     */
    static func compactAddressIPv6(ipAddress: String) -> String {
        var shortAddr = String()
        var ip4Hex = [String]()
        var prevIsZero = false
        var prevAreZero = false
        var prevCompactZero = false
        var prevNonZero = false
        
        //print("IP Address: \(ipAddress)")
        ip4Hex = IPSubnetCalc.fullAddressIPv6(ipAddress: ipAddress).components(separatedBy: ":")
        for index in 0...(ip4Hex.count - 1) {
            if (UInt16(ip4Hex[index], radix: 16)! == 0) {
                if (!prevIsZero || prevCompactZero) {
                    if index == (ip4Hex.count - 1) {
                        shortAddr.append("0")
                    }
                    else {
                        shortAddr.append("0:")
                    }
                }
                else if (prevIsZero && !prevAreZero) {
                    shortAddr.removeLast(2)
                    prevAreZero = true
                }
                if (prevIsZero && index == (ip4Hex.count - 1)) {
                    if (shortAddr == "") {
                        shortAddr.append("::")
                    }
                    else {
                        shortAddr.append(":")
                    }
                }
                prevIsZero = true
            }
            else {
                if (prevAreZero && !prevCompactZero) {
                    if (!prevNonZero) {
                        shortAddr.append("::")
                    }
                    else {
                        shortAddr.append(":")
                    }
                    prevCompactZero = true
                }
                shortAddr.append(String(UInt16(ip4Hex[index], radix: 16)!, radix: 16))
                if (index != (ip4Hex.count - 1)) {
                    shortAddr.append(":")
                }
                prevIsZero = false
                prevAreZero = false
                prevNonZero = true
            }
            //print("Index : \(index) IPHex : \(ip4Hex[index]) shortAddr: \(shortAddr)")
        }
        return (shortAddr)
    }
    
    /**
     Returns IPv6 Network address
     
     - Returns:
     the Network address in hexadecimal format of the current IPv6 address
     
     */
    func networkIPv6() -> String {
        var netID = [UInt16]()
        let numMask = IPSubnetCalc.digitizeMaskIPv6(maskbits: self.ipv6MaskBits)
        let numIP = IPSubnetCalc.digitizeIPv6(ipAddress: self.ipv6Address)
        
        for index in 0...7 {
            //print("Index: \(index) IP: \(numIP[index]) Mask : \(numMask[index]) Result : \(numIP[index] & (numMask[index])) ")
            netID.append((numIP[index] & numMask[index]))
        }
        return (IPSubnetCalc.hexarizeIPv6(num: netID, full: false, column: true))
    }
    
    /**
     Returns IPv6 Network Range
     
     - Returns:
     First IPv6 address - Last IPv6 address of the current IPv6 address/mask
     
     */
    func networkRangeIPv6() -> String {
        var netID = [UInt16]()
        var netID2 = [UInt16]()
        let numMask = IPSubnetCalc.digitizeMaskIPv6(maskbits: self.ipv6MaskBits)
        let numIP = IPSubnetCalc.digitizeIPv6(ipAddress: self.ipv6Address)
        
        for index in 0...7 {
            //print("Index: \(index) IP: \(numIP[index]) Mask : \(numMask[index]) Result : \(numIP[index] & (numMask[index])) ")
            netID.append((numIP[index] & numMask[index]))
        }
        for index in 0...7 {
            //print("Index: \(index) IP: \(numIP[index]) Mask : \(numMask[index]) Result : \(numIP[index] & (numMask[index])) ")
            netID2.append((numIP[index] | ~numMask[index]))
        }
        var netIDStr = IPSubnetCalc.hexarizeIPv6(num: netID, full: true, column: true)
        netIDStr.append(" - \(IPSubnetCalc.hexarizeIPv6(num: netID2, full: true, column: true))")
        return (netIDStr)
    }
    
    /**
     Returns Total IP addresses for IPv6
     
     - Returns:
     Total IP addresses for the current IPv6 mask
     
     */
    func totalIPAddrIPv6() -> Decimal {
        var total = Decimal()
        var number: Decimal = 2
        
        NSDecimalPower(&total, &number , (128 - self.ipv6MaskBits), NSDecimalNumber.RoundingMode.plain)
        return (total)
    }
    
    /**
     Returns IPv6 address in dotted decimal format
     
     - Returns:
     IPv6 address in dotted decimal format of the current IPv6 address
     
     */
    func dottedDecimalIPv6() -> String {
        var ipv4str = String()
        
        let ip4Hex = IPSubnetCalc.fullAddressIPv6(ipAddress: self.ipv6Address).components(separatedBy: ":")
        for index in (0...(ip4Hex.count - 1)) {
            if (index != 0) {
                ipv4str.append(".")
                
            }
            if (ip4Hex[index] == "") {
                ipv4str.append("0.0")
            }
            else {
                ipv4str.append(String((UInt32(ip4Hex[index], radix: 16)! & Constants.addr32Digit3) >> 8))
                ipv4str.append("." + String((UInt32(ip4Hex[index], radix: 16)! & Constants.addr32Digit4)))
            }
        }
        return ipv4str
    }
    
    /**
     Returns IPv6 address in IP6 ARPA notation
     
     - Returns:
     IPv6 address in IP6 ARPA notation of the current IPv6 address
     
     */
    func ip6ARPA () -> String {
        var ipARPA = IPSubnetCalc.fullAddressIPv6(ipAddress: self.ipv6Address)
        let delimiter: Set<Character> = [":"]
        
        ipARPA.removeAll(where: { delimiter.contains($0) })
        ipARPA = String(ipARPA.reversed())
        
        var offset = ipARPA.index(ipARPA.startIndex, offsetBy: 1)
        for _ in 0...(ipARPA.count - 2) {
            ipARPA.insert(".", at: offset)
            offset = ipARPA.index(offset, offsetBy: 2)
        }
        ipARPA.append(".ip6.arpa")
        return (ipARPA)
    }
    
    /**
     Returns the reserved IPv6 block name if it exists
     
     - Returns:
      reserved IPv6 block name or nil if it does not exist
     
     */
    func resBlockIPv6() -> String? {
        var netID = networkIPv6()
        
        netID = IPSubnetCalc.fullAddressIPv6(ipAddress: netID)
        //print("NetID BEFORE compact : \(netID)")
        netID = IPSubnetCalc.compactAddressIPv6(ipAddress: netID)
        //print("NetID AFTER compact : \(netID)")
        netID.append("/\(self.ipv6MaskBits)")
        
        for item in Constants.resIPv6Blocks {
            if (item.key == netID) {
                return (item.value + " (\(item.key))")
            }
        }
        return nil
    }
    
    /**
     Initialize an IPv4 object
     
     - Parameters:
        - ipAddress: IPv4 address in its dotted decimal format
        - maskbits: number of mask bits as in /XX notation
     
     - Returns:
     nil if the IPv4 address or mask is not valid
     
     */
    init?(ipAddress: String, maskbits: Int) {
        do {
        try IPSubnetCalc.validateIPv4(ipAddress: ipAddress, mask: String(maskbits), classless: true)
            self.ipv4Address = ipAddress
            self.maskBits = maskbits
            self.ipv6Address = IPSubnetCalc.convertIPv4toIPv6(ipAddress: ipAddress)
            self.ipv6MaskBits = maskbits + Constants.defaultIPv6to4Mask
        }
        catch {
            print("Init error: \(error)")
            return nil
        }
    }
    
    /**
     Initialize an IPv4 object with the default mask of its network class
     
     - Parameters:
        - ipAddress: IPv4 address in its dotted decimal format
     
     - Returns:
     nil if the IPv4 address is not valid
     
     */
    convenience init?(_ ipAddress: String) {
        var classbit: Int
        
        do {
            try IPSubnetCalc.validateIPv4(ipAddress: ipAddress, mask: nil)
            switch (IPSubnetCalc.netClass(ipAddress: ipAddress)) {
            case "A":
                classbit = Constants.classAbits
            case "B":
                classbit = Constants.classBbits
            case "C":
                classbit = Constants.classCbits
            default:
                classbit = Constants.classAbits
            }
            self.init(ipAddress: ipAddress, maskbits: classbit)
        }
        catch {
            print("Init error: \(error)")
            return nil
        }
    }
    
    /**
     Initialize an IPv6 object
     
     - Parameters:
        - ipv6: IPv6 address in its hexadecimal format
        - maskbits: number of mask bits as in /XX notation
     
     - Returns:
     nil if the IPv6 address or mask is not valid
     
     */
    init?(ipv6: String, maskbits: Int) {
        do {
        try IPSubnetCalc.validateIPv6(ipAddress: ipv6, mask: maskbits)
            (self.ipv4Address, _) = IPSubnetCalc.convertIPv6toIPv4(ipAddress: ipv6)
            if (maskbits >= (Constants.defaultIPv6to4Mask + Constants.classAbits)) {
                self.maskBits = maskbits - Constants.defaultIPv6to4Mask
            }
            else {
                self.maskBits = Constants.classAbits
            }
            
            // full ? compact ? validated ?
            self.ipv6Address = ipv6
            self.ipv6MaskBits = maskbits
            //print("init IPv6 ipv6 addr: \(self.ipv6Address) ipv4 addr: \(self.ipv4Address)")
        }
        catch {
            print("Init error: \(error)")
            return nil
        }
    }
}
