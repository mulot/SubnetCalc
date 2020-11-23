//
//  IPSubnetcalc.swift
//  SubnetCalc
//
//  Created by Julien Mulot on 22/11/2020.
//

import Foundation
import Cocoa


class IPSubnetCalc: NSObject {
    //*************
    //Constants
    //*************
    enum Constants {
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
    
    //*************
    //Properties
    //*************
    var ipv4Address: String
    var networkClass: String
    var netId: UInt
    var netBits: Int
    var mask: UInt
    var subnetMax: UInt
    var subnetBits: Int
    var maskBits: Int
    var subnetBitsMax: Int
    var subnetMask: UInt
    var hostBits: Int
    var hostMax: UInt
    var hostAddr: UInt
    var hostId: UInt
    var hostSubnetLbound: UInt
    var hostSubnetUbound: UInt
    var ciscoWildcard: UInt
    var bitMap: String
    
    //*************
    //IPv4 SECTION
    //*************
    static func binarize(ipAddress: String) -> String {
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
            digitBin.insert(" ", at: ipAddressBin[index].index(ipAddressBin[index].startIndex, offsetBy: 4))
            if (index < 3) {
                binStr += digitBin + "."
            }
            else {
                binStr += digitBin
            }
        }
        return (binStr)
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
    
    static func numerize(ipAddress: String) -> UInt32 {
        var ipAddressNum: UInt32 = 0
        var ipDigits = [String]()
        
        ipDigits = ipAddress.components(separatedBy: ".")
        
        for index in 0...3 {
            ipAddressNum += UInt32(ipDigits[index])! << (32 - 8 * (index + 1))
        }
        return (ipAddressNum & Constants.addr32Full)
    }
    
    static func numerize(mask: String) -> UInt32 {
        var maskNum: UInt32 = 0
        
        maskNum = (Constants.addr32Full << (32 - Int(mask)!)) & Constants.addr32Full
        return (maskNum)
    }
    
    static func digitize(ipAddress: UInt32) -> String {
        var ipDigits = String()
        
        ipDigits.append(String(((ipAddress & Constants.addr32Digit1) >> 24)) + ".")
        ipDigits.append(String(((ipAddress & Constants.addr32Digit2) >> 16)) + ".")
        ipDigits.append(String(((ipAddress & Constants.addr32Digit3) >> 8)) + ".")
        ipDigits.append(String(((ipAddress & Constants.addr32Digit4))))
        return (ipDigits)
    }
    
    func splitAddrMask(address: String) -> (String, String) {
        let ipInfo = address.split(separator: "/")
        if ipInfo.count == 2 {
            //CHECK if String convert is needed?
            return (String(ipInfo[0]), String(ipInfo[1]))
        }
        else if ipInfo.count > 2 {
            print("Bad IP format: \(ipInfo)")
            return ("", "")
        }
        return (address, "")
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
                if (maskNum < 0 || maskNum > 32) {
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
            print("null mask")
        }
        return true
    }
    
    func subnetId(ipAddress: String, mask: String) -> UInt32 {
        var subnetId: UInt32 = 0
        let ipBits = IPSubnetCalc.numerize(ipAddress: ipAddress)
        let maskBits = IPSubnetCalc.numerize(mask: mask)
        
        subnetId = ipBits & maskBits
        return (subnetId)
    }
    
    func subnetBroadcast(ipAddress: String, mask: String) -> UInt32 {
        var broadcast: UInt32 = 0
        let ipBits = IPSubnetCalc.numerize(ipAddress: ipAddress)
        let maskBits = IPSubnetCalc.numerize(mask: mask)
        
        broadcast = ipBits & maskBits | (Constants.addr32Full >> Int(mask)!)
        return (broadcast)
    }
    
    func subnetMask(mask: String) -> UInt32 {
        var subnetMask: UInt32 = 0
        
        subnetMask = Constants.addr32Full << (32 - Int(mask)!)
        return (subnetMask)
    }
    
    func wildcardMask(mask: String) -> UInt32 {
        var wildcardMask: UInt32 = 0
        
        wildcardMask = ~(Constants.addr32Full << (32 - Int(mask)!))
        return (wildcardMask)
    }
    
    func maxHosts(mask: String) -> String {
        var maxHosts: UInt32 = 0
        
        maxHosts = (Constants.addr32Full >> UInt32(mask)!) - 1
        return (String(maxHosts))
    }
    
    func maxCIDRSubnets(mask: String) -> String {
        var max: Int = 0
        
        max = Int(truncating: NSDecimalNumber(decimal: pow(2, (32 - Int(mask)!))))
        return (String(max))
    }
    
    func subnetRange(ipAddress: String, mask: String) -> String {
        var range = String()
        var firstIP: UInt32 = 0
        var lastIP: UInt32 = 0
        
        firstIP = subnetId(ipAddress: ipAddress, mask: mask) + 1
        lastIP = subnetBroadcast(ipAddress: ipAddress, mask: mask) - 1
        range = IPSubnetCalc.digitize(ipAddress: firstIP) + " - " + IPSubnetCalc.digitize(ipAddress: lastIP)
        return (range)
    }
    
    func subnetCIDRRange(ipAddress: String, mask: String) -> String {
        var range = String()
        var firstIP: UInt32 = 0
        var lastIP: UInt32 = 0
        
        firstIP = subnetId(ipAddress: ipAddress, mask: mask)
        lastIP = subnetBroadcast(ipAddress: ipAddress, mask: mask)
        range = IPSubnetCalc.digitize(ipAddress: firstIP) + " - " + IPSubnetCalc.digitize(ipAddress: lastIP)
        return (range)
    }
    
    func netClass(ipAddress: String) -> String {
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
    
    func subnetBits(ipAddress: String, mask: String) -> String {
        let classType = netClass(ipAddress: ipAddress)
        var bits: Int = 0
        
        if (classType == "A") {
            bits = Int(mask)! - 8
        }
        else if (classType == "B") {
            bits = Int(mask)! - 16
        }
        else if (classType == "C") {
            bits = Int(mask)! - 24
        }
        if (bits < 0) {
            bits = 0
        }
        return (String(bits))
    }
    
    func maxSubnets(ipAddress: String, mask: String) -> String {
        var maxSubnets: Int = 0
        
        let bits = subnetBits(ipAddress: ipAddress, mask: mask)
        maxSubnets = Int(truncating: NSDecimalNumber(decimal: pow(2, Int(bits)!)))
        return (String(maxSubnets))
    }
    
    func bitMap(ipAddress: String, mask: String) -> String {
        let mask_num = IPSubnetCalc.numerize(mask: mask)
        let classAddr = netClass(ipAddress: ipAddress)
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
    
    func displayIPInfo(ipAddress: String, mask: String) {
        if (IPSubnetCalc.isValidIP(ipAddress: ipAddress, mask: mask)) {
            print("IP Host : " + ipAddress)
            print("Mask bits : " + mask)
            print("Mask : " + IPSubnetCalc.digitize(ipAddress: subnetMask(mask: mask)))
            print("Subnet bits : " + subnetBits(ipAddress: ipAddress, mask: mask))
            print("Subnet ID : " + IPSubnetCalc.digitize(ipAddress: subnetId(ipAddress: ipAddress, mask: mask)))
            print("Broadcast : " + IPSubnetCalc.digitize(ipAddress: subnetBroadcast(ipAddress: ipAddress, mask: mask)))
            print("Max Host : " + maxHosts(mask: mask))
            print("Max Subnet : " + maxSubnets(ipAddress: ipAddress, mask: mask))
            print("Subnet Range : " + subnetRange(ipAddress: ipAddress, mask: mask))
            print("IP Class Type : " + netClass(ipAddress: ipAddress))
            print("Hexa IP : " + IPSubnetCalc.hexarize(ipAddress: ipAddress))
            print("Binary IP : " + IPSubnetCalc.binarize(ipAddress: ipAddress))
            print("BitMap : " + bitMap(ipAddress: ipAddress, mask: mask))
            print("CIDR Netmask : " + IPSubnetCalc.digitize(ipAddress: subnetMask(mask: mask)))
            print("Wildcard Mask : " + IPSubnetCalc.digitize(ipAddress: wildcardMask(mask: mask)))
            print("CIDR Max Subnet : " + maxCIDRSubnets(mask: mask))
            print("CIDR Max Hosts : " + maxHosts(mask: mask))
            print("CIDR Network (Route) : " + IPSubnetCalc.digitize(ipAddress: subnetId(ipAddress: ipAddress, mask: mask)))
            print("CIDR Net Notation : " + IPSubnetCalc.digitize(ipAddress: subnetId(ipAddress: ipAddress, mask: mask)) + "/" + mask)
            print("CIDR Address Range : " + subnetCIDRRange(ipAddress: ipAddress, mask: mask))
            print("IP number in binary : " + String(IPSubnetCalc.numerize(ipAddress: ipAddress), radix: 2))
            //print("IP number reverse : " + digitize(ipAddress: numerize(ipAddress: ipAddress)))
            print("Mask bin : " + String(IPSubnetCalc.numerize(mask: mask), radix: 2))
            print("Subnet ID bin : " + String(subnetId(ipAddress: ipAddress, mask: mask), radix: 2))
            print("Broadcast bin : " + String(subnetBroadcast(ipAddress: ipAddress, mask: mask), radix: 2))
        }
        else {
            print("IP \(ipAddress) is not valid")
        }
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
    
    static func numerizeMask(maskbits: Int) -> [UInt16] {
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
    
    static func hexarize(num: [UInt16], full: Bool = true, column: Bool = false) -> String {
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
    
    func getHexID(ipAddress: String) -> String {
        var hexID: String = ipAddress
        let delimiter: Set<Character> = [":"]
        hexID.removeAll(where: { delimiter.contains($0) })
        return("0x\(hexID)")
    }
    
    func getBinID(ipAddress: String) -> String {
        return (IPSubnetCalc.binarizeIPv6(ipAddress: ipAddress))
    }
    
    func getIPv6Digit(ipAddress: String) -> String {
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
    
    func fullIPv6Address(ipAddress: String) -> String {
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
    
    func compactIPv6Address(ipAddress: String) -> String {
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
    
    func networkID(ipAddress: String, maskbits: Int) -> String {
        var netID = [UInt16]()
        let numMask = IPSubnetCalc.numerizeMask(maskbits: maskbits)
        let numIP = IPSubnetCalc.numerizeIPv6(ipAddress: fullIPv6Address(ipAddress: ipAddress))
        let nbIndex = maskbits / 16
        
        for index in 0...nbIndex {
            if (index < 8) {
                //print("Index: \(index) IP: \(numIP[index]) Mask : \(numMask[index]) Result : \(numIP[index] & (numMask[index])) ")
                netID.append((numIP[index] & numMask[index]))
            }
        }
        var netIDStr = IPSubnetCalc.hexarize(num: netID, full: false, column: true)
        if (nbIndex < 7) {
            netIDStr.append("::")
        }
        return (netIDStr)
    }
    
    func networkRange(ipAddress: String, maskbits: Int) -> String {
        var netID = [UInt16]()
        var netID2 = [UInt16]()
        let numMask = IPSubnetCalc.numerizeMask(maskbits: maskbits)
        let numIP = IPSubnetCalc.numerizeIPv6(ipAddress: ipAddress)
        
        for index in 0...7 {
            //print("Index: \(index) IP: \(numIP[index]) Mask : \(numMask[index]) Result : \(numIP[index] & (numMask[index])) ")
            netID.append((numIP[index] & numMask[index]))
        }
        for index in 0...7 {
            //print("Index: \(index) IP: \(numIP[index]) Mask : \(numMask[index]) Result : \(numIP[index] & (numMask[index])) ")
            netID2.append((numIP[index] | ~numMask[index]))
        }
        var netIDStr = IPSubnetCalc.hexarize(num: netID, full: true, column: true)
        netIDStr.append(" - \(IPSubnetCalc.hexarize(num: netID2, full: true, column: true))")
        return (netIDStr)
    }
    
    func getTotalIPAddr(maskbits: Int) -> Decimal {
        var total = Decimal()
        var number: Decimal = 2
        
        NSDecimalPower(&total, &number , (128 - maskbits), NSDecimalNumber.RoundingMode.plain)
        //return (pow(2, Double(128 - maskbits)))
        return (total)
    }
    
    func ip6ARPA (ipAddress: String) -> String {
        var ipARPA = fullIPv6Address(ipAddress: ipAddress)
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
    
    func resIPv6Block(ipAddress: String, maskbits: Int) -> String? {
        var netID = networkID(ipAddress: ipAddress, maskbits: maskbits)
        
        netID = fullIPv6Address(ipAddress: netID)
        //print("NetID BEFORE compact : \(netID)")
        netID = compactIPv6Address(ipAddress: netID)
        //print("NetID AFTER compact : \(netID)")
        netID.append("/\(maskbits)")
        
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
            self.networkClass = "A"
            self.netId = 0
            self.netBits = 0
            self.mask = 0
            self.subnetMax = 0
            self.subnetBits = 0
            self.maskBits = maskbits
            self.subnetBitsMax = 0
            self.subnetMask = 0
            self.hostBits = 0
            self.hostMax = 0
            self.hostAddr = 0
            self.hostId = 0
            self.hostSubnetLbound = 0
            self.hostSubnetUbound = 0
            self.ciscoWildcard = 0
            self.bitMap = ""
        }
        else {
            return nil
        }
    }
    
    convenience init?(_ ipAddress: String) {
        self.init(ipAddress: ipAddress, maskbits: 8)
    }
}
