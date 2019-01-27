//
//  SightingDateFomatter.swift
//  Lifelist
//
//  Created by Jonathan Arbogast on 1/27/19.
//  Copyright © 2019 Jonathan Arbogast. All rights reserved.
//

import Foundation

final class SightingDateFormatter: DateFormatter {
    override init() {
        super.init()
        self.dateStyle = .medium
        self.timeStyle = .short
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
