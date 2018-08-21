//
//  FIDocumentPreferencesOutput.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/21/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Foundation

extension FIDocument: PreferencesOutput {
    func update(_ preferences: Preferences) {
        self.model.preferences = preferences
    }
}
