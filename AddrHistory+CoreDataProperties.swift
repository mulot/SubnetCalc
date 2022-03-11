//
//  AddrHistory+CoreDataProperties.swift
//  SubnetCalc
//
//  Created by Julien Mulot on 11/03/2022.
//
//

import Foundation
import CoreData


extension AddrHistory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AddrHistory> {
        return NSFetchRequest<AddrHistory>(entityName: "AddrHistory")
    }

    @NSManaged public var address: String

}
