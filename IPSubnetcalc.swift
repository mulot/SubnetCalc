//
//  IPSubnetcalc.swift
//  SubnetCalc
//
//  Created by Julien Mulot on 22/11/2020.
//

import Foundation
import Cocoa


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
        static let addr128Full: [UInt16] = [addr16Full, addr16Full, addr16Full, addr16Full, addr16Full, addr16Full, addr16Full, addr16Full]
        static let addr128Empty: [UInt16] = [addr16Empty, addr16Empty, addr16Empty, addr16Empty, addr16Empty, addr16Empty, addr16Empty, addr16Empty]
        static let addr16Hex1: UInt16 = 0xF000
        static let addr16Hex2: UInt16 = 0x0F00
        static let addr16Hex3: UInt16 = 0x00F0
        static let addr16Hex4: UInt16 = 0x000F
        static let resIPv6Blocks: [String : String] = ["::1/128" : "Loopback Address",
                                                       "::/128" : " Unspecified Address",
                                                       "2001:db8::/32" : "Documentation"]
        
        //IPv4 constants
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
        static let netIdClassC: UInt32 = 0xc0000000
        static let maskClassC: UInt32 = 0xFFFFFF00
    }
    
    //****************
    //Class Properties
    //****************
    var ipv4Address: String
    var maskBits: Int
    var ipv6Address: String
    var maskBitsIPv6: Int
    
    
    //*************
    //IPv4 SECTION
    //*************
    static func binarize(ipAddress: String, space: Bool) -> String {
        var ipAddressBin = [String]()
        var binStr = String()
        var ipDigits = [String]()
        
        ipDigits = ipAddress.components(separatedBy: ".")
        
        for index in 0...3 {
            ipAddressBin.append(String(Int(ipDigits[index])!, radix: 2))
            while (ipAddressBin[index].count < 8) {
                ipAddressBin[index].insert("0", at: ipAddressBin[index].startIndex)
            }
            
            var digitBin = ipAddressBin[index]
            if (space == true) {
                digitBin.insert(" ", at: ipAddressBin[index].index(ipAddressBin[index].startIndex, offsetBy: 4))
            }
            if (index < 3) {
                binStr += digitBin + "."
            }
            else {
                binStr += digitBin
            }
        }
        return (binStr)
    }
    
    func binaryMap() -> String {
        return (IPSubnetCalc.binarize(ipAddress: ipv4Address, space: false))
    }
    
    static func hexarize(ipAddress: String) -> String {
        var ipDigits = [String]()
        var hexIP = String()
        var hex4: String
        
        ipDigits = ipAddress.components(separatedBy: ".")
        for index in 0...3 {
            hex4 = String(format: "%X", Int(ipDigits[index])!)
            if (hex4.count == 1) {
                hex4 = "0" + hex4
            }
            hexIP += hex4
            if (index < 3) {
                hexIP += "."
            }
        }
        return (hexIP)
    }
    
    func hexaMap() -> String {
        return (IPSubnetCalc.hexarize(ipAddress: ipv4Address))
    }
    
    static func numerize(ipAddress: String) -> UInt32 {
        var ipAddressNum: UInt32 = 0
        var ipDigits = [String]()
        
        ipDigits = ipAddress.components(separatedBy: ".")
        
        for index in 0...3 {
            ipAddressNum += UInt32(ipDigits[index])! << (32 - 8 * (index + 1))
        }
        return (ipAddressNum & Constants.addr32Full)
    }
    
    //numerize a String as a Decimal value to UInt32
    static func numerize(str: String) -> UInt32 {
        var maskNum: UInt32 = 0
        
        if (Int(str) != nil) {
            maskNum = (Constants.addr32Full << (32 - Int(str)!)) & Constants.addr32Full
        }
        return (maskNum)
    }
    
    static func numerize(number: Int) -> UInt32 {
        return ((Constants.addr32Full << (32 - number)) & Constants.addr32Full)
    }
    
    static func digitize(ipAddress: UInt32) -> String {
        var ipDigits = String()
        
        ipDigits.append(String(((ipAddress & Constants.addr32Digit1) >> 24)) + ".")
        ipDigits.append(String(((ipAddress & Constants.addr32Digit2) >> 16)) + ".")
        ipDigits.append(String(((ipAddress & Constants.addr32Digit3) >> 8)) + ".")
        ipDigits.append(String(((ipAddress & Constants.addr32Digit4))))
        return (ipDigits)
    }
    
    static func isValidIP(ipAddress: String, mask: String?) -> Bool {
        var ip4Digits = [String]()
        
        ip4Digits = ipAddress.components(separatedBy: ".")
        if (ip4Digits.count == 4) {
            for item in ip4Digits {
                if let digit = Int(item, radix: 10) {
                    if (digit > 255) {
                        print("bad IP digit \(digit)")
                        return false
                    }
                }
                else {
                    print("not digit: \(item)")
                    return false
                }
            }
        }
        else {
            print("bad IP format \(ip4Digits)")
            return false
        }
        if mask != nil {
            if let maskNum = Int(mask!) {
                if (maskNum < Constants.NETWORK_BITS_MIN || maskNum > Constants.NETWORK_BITS_MAX) {
                    print("mask \(maskNum) invalid")
                    return false
                }
            }
            else {
                print("mask \(mask!) is not digit")
                return false
            }
        }
        else {
            //print("null mask")
        }
        return true
    }
    
    func subnetId() -> String {
        var subnetId: UInt32 = 0
        let ipBits = IPSubnetCalc.numerize(ipAddress: self.ipv4Address)
        let maskBits = IPSubnetCalc.numerize(number: self.maskBits)
        
        subnetId = ipBits & maskBits
        return (IPSubnetCalc.digitize(ipAddress: subnetId))
    }
    
    func subnetBroadcast() -> String {
        var broadcast: UInt32 = 0
        let ipBits = IPSubnetCalc.numerize(ipAddress: self.ipv4Address)
        let maskBits = IPSubnetCalc.numerize(number: self.maskBits)
        
        broadcast = ipBits & maskBits | (Constants.addr32Full >> self.maskBits)
        return (IPSubnetCalc.digitize(ipAddress: broadcast))
    }
    
    func subnetMask() -> String {
        var subnetMask: UInt32 = 0
        
        subnetMask = Constants.addr32Full << (32 - self.maskBits)
        return (IPSubnetCalc.digitize(ipAddress: subnetMask))
    }
    
    func wildcardMask() -> String {
        var wildcardMask: UInt32 = 0
        
        wildcardMask = ~(Constants.addr32Full << (32 - self.maskBits))
        return (IPSubnetCalc.digitize(ipAddress: wildcardMask))
    }
    
    func maxHosts() -> Int {
        var maxHosts: UInt32 = 0
        
        maxHosts = (Constants.addr32Full >> self.maskBits) - 1
        return (Int(maxHosts))
    }
    
    func maxCIDRSubnets() -> Int {
        var max: Int = 0
        
        max = Int(truncating: NSDecimalNumber(decimal: pow(2, (32 - self.maskBits))))
        //max = Int(truncating: pow(2, (32 - self.maskBits)) as NSDecimalNumber)
        return (max)
    }
    
    func subnetRange() -> String {
        var range = String()
        var firstIP: UInt32 = 0
        var lastIP: UInt32 = 0
        
        firstIP = IPSubnetCalc.numerize(ipAddress: subnetId()) + 1
        lastIP = IPSubnetCalc.numerize(ipAddress: subnetBroadcast()) - 1
        range = IPSubnetCalc.digitize(ipAddress: firstIP) + " - " + IPSubnetCalc.digitize(ipAddress: lastIP)
        return (range)
    }
    
    func subnetCIDRRange() -> String {
        var range = String()
        var firstIP: UInt32 = 0
        var lastIP: UInt32 = 0
        
        firstIP = IPSubnetCalc.numerize(ipAddress: subnetId())
        lastIP = IPSubnetCalc.numerize(ipAddress: subnetBroadcast())
        range = IPSubnetCalc.digitize(ipAddress: firstIP) + " - " + IPSubnetCalc.digitize(ipAddress: lastIP)
        return (range)
    }
    
    static func netClass(ipAddress: String) -> String {
        let ipNum = IPSubnetCalc.numerize(ipAddress: ipAddress)
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
        return ("D")
    }
    
    func netClass() -> String {
        return (IPSubnetCalc.netClass(ipAddress: ipv4Address))
    }
    
    func subnetBits() -> Int {
        let classType = self.netClass()
        var bits: Int = 0
        
        if (classType == "A") {
            bits = self.maskBits - 8
        }
        else if (classType == "B") {
            bits = self.maskBits - 16
        }
        else if (classType == "C") {
            bits = self.maskBits - 24
        }
        return (bits)
    }
    
    static func maskBits(maskAddr: String) -> Int {
        var bits: Int = 0
        
        var mask:UInt32 = IPSubnetCalc.numerize(ipAddress: maskAddr)
        while (mask != 0) {
            bits += 1
            mask <<= 1
        }
        //print("maskBits \(maskAddr) bits: \(bits)")
        return (bits)
    }
    
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
    
    func netBits() -> Int {
        let classType = self.netClass()
        var bits: Int = 0
        
        if (classType == "A") {
            bits =  8
        }
        else if (classType == "B") {
            bits = 16
        }
        else if (classType == "C") {
            bits = 24
        }
        return (bits)
    }
    
    func maxSubnets() -> Int {
        var maxSubnets: Int = 0
        
        let bits = subnetBits()
        maxSubnets = Int(truncating: NSDecimalNumber(decimal: pow(2, bits)))
        return (maxSubnets)
    }
    
    func bitMap() -> String {
        let mask_num = IPSubnetCalc.numerize(number: maskBits)
        let classAddr = self.netClass()
        var maskClass: UInt32 = 0
        var bitMap = String()
        
        if (classAddr == "A") {
            maskClass = Constants.maskClassA
        }
        else if (classAddr == "B") {
            maskClass = Constants.maskClassB
        }
        else if (classAddr == "C") {
            maskClass = Constants.maskClassC
        }
        
        for index in 0...31 {
            if (((mask_num >> index) & maskClass) > 0) {
                bitMap.append("n")
            }
            else if (((mask_num >> index) & mask_num) > 0) {
                bitMap.append("s")
            }
            else {
                bitMap.append("h")
            }
            if ((index < 31) && ((index + 1) % 8 == 0)) {
                bitMap.append(".")
            }
        }
        return (bitMap)
    }
    
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
        print("IP number in binary : " + String(IPSubnetCalc.numerize(ipAddress: self.ipv4Address), radix: 2))
        print("Mask bin : " + String(IPSubnetCalc.numerize(number: self.maskBits), radix: 2))
        //print("Subnet ID bin : " + String(self.subnetId(), radix: 2))
        //print("Broadcast bin : " + String(self.subnetBroadcast(), radix: 2))
    }
    
    //*************
    //IPv6 SECTION
    //*************
    static func numerizeIPv6(ipAddress: String) -> [UInt16] {
        var ipAddressNum: [UInt16] = Array(repeating: 0, count: 8)
        var ip4Hex = [String]()
        
        ip4Hex = ipAddress.components(separatedBy: ":")
        for index in 0...7 {
            ipAddressNum[index] = UInt16(ip4Hex[index], radix: 16)!
            //print("Index: \(index) Ip4Hex: \(ip4Hex[index]) Hexa : \(UInt16(ip4Hex[index], radix: 16)!)")
        }
        return (ipAddressNum)
    }
    
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
    
    static func numerizeMaskIPv6(maskbits: Int) -> [UInt16] {
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
    
    func hexaIDIPv6() -> String {
        var hexID: String = self.ipv6Address
        let delimiter: Set<Character> = [":"]
        hexID.removeAll(where: { delimiter.contains($0) })
        return("0x\(hexID)")
    }
    
    func binaryIDIPv6() -> String {
        return (IPSubnetCalc.binarizeIPv6(ipAddress: self.ipv6Address))
    }
    
    func digitizeIPv6(ipAddress: String) -> String {
        var digitStr = String()
        let numIP = IPSubnetCalc.numerizeIPv6(ipAddress: ipAddress)
        
        for index in 0...7  {
            if (index != 7) {
                digitStr.append("\(numIP[index]):")
            }
            else {
                digitStr.append("\(numIP[index])")
            }
        }
        return (digitStr)
    }
    
    func fullAddressIPv6(ipAddress: String) -> String {
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
    
    func compactAddressIPv6(ipAddress: String) -> String {
        var shortAddr = String()
        var ip4Hex = [String]()
        var prevIsZero = false
        var prevAreZero = false
        var prevCompactZero = false
        
        //print("IP Address: \(ipAddress)")
        ip4Hex = ipAddress.components(separatedBy: ":")
        for index in 0...(ip4Hex.count - 1) {
            //print("Index : \(index) IPHex : \(ip4Hex[index]) Dec : \(String(UInt16(ip4Hex[index], radix: 16)!, radix: 16))")
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
                    if index == (ip4Hex.count - 1) {
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
            }
            
        }
        return (shortAddr)
    }
    
    func networkIDIPv6() -> String {
        var netID = [UInt16]()
        let numMask = IPSubnetCalc.numerizeMaskIPv6(maskbits: self.maskBitsIPv6)
        let numIP = IPSubnetCalc.numerizeIPv6(ipAddress: fullAddressIPv6(ipAddress: self.ipv6Address))
        let nbIndex = self.maskBitsIPv6 / 16
        
        for index in 0...nbIndex {
            if (index < 8) {
                //print("Index: \(index) IP: \(numIP[index]) Mask : \(numMask[index]) Result : \(numIP[index] & (numMask[index])) ")
                netID.append((numIP[index] & numMask[index]))
            }
        }
        var netIDStr = IPSubnetCalc.hexarizeIPv6(num: netID, full: false, column: true)
        if (nbIndex < 7) {
            netIDStr.append("::")
        }
        return (netIDStr)
    }
    
    func networkRangeIPv6() -> String {
        var netID = [UInt16]()
        var netID2 = [UInt16]()
        let numMask = IPSubnetCalc.numerizeMaskIPv6(maskbits: self.maskBitsIPv6)
        let numIP = IPSubnetCalc.numerizeIPv6(ipAddress: self.ipv6Address)
        
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
    
    func totalIPAddrIPv6() -> Decimal {
        var total = Decimal()
        var number: Decimal = 2
        
        NSDecimalPower(&total, &number , (128 - self.maskBitsIPv6), NSDecimalNumber.RoundingMode.plain)
        return (total)
    }
    
    func ip6ARPA () -> String {
        var ipARPA = fullAddressIPv6(ipAddress: self.ipv6Address)
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
    
    func resBlockIPv6() -> String? {
        var netID = networkIDIPv6()
        
        netID = fullAddressIPv6(ipAddress: netID)
        //print("NetID BEFORE compact : \(netID)")
        netID = compactAddressIPv6(ipAddress: netID)
        //print("NetID AFTER compact : \(netID)")
        netID.append("/\(self.maskBitsIPv6)")
        
        for item in Constants.resIPv6Blocks {
            if (item.key == netID) {
                return (item.value + " (\(item.key))")
            }
        }
        return nil
    }
    
    init?(ipAddress: String, maskbits: Int) {
        if (IPSubnetCalc.isValidIP(ipAddress: ipAddress, mask: String(maskbits))) {
            self.ipv4Address = ipAddress
            self.maskBits = maskbits
            self.ipv6Address = "2001:db8::"
            self.maskBitsIPv6 = 32
        }
        else {
            return nil
        }
    }
    
    convenience init?(_ ipAddress: String) {
        var classbit: Int
        
        if (IPSubnetCalc.isValidIP(ipAddress: ipAddress, mask: nil)) {
            switch (IPSubnetCalc.netClass(ipAddress: ipAddress)) {
            case "A":
                classbit = 8
            case "B":
                classbit = 16
            case "C":
                classbit = 24
            default:
                classbit = 8
            }
            self.init(ipAddress: ipAddress, maskbits: classbit)
        }
        else {
            return nil
        }
    }
    
    init?(ipv6: String, maskbits: Int) {
        self.ipv4Address = ""
        self.maskBits = 0
        
        // full ? compact ? validated ?
        self.ipv6Address = ipv6
        self.maskBitsIPv6 = maskbits
        return nil
    }
}
