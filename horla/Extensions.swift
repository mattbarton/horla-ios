//
//  Extensions.swift
//  horla
//
//  Created by matt on 12/11/15.
//  Copyright © 2015 Proper Tea. All rights reserved.
//

import Foundation

extension String
{
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}