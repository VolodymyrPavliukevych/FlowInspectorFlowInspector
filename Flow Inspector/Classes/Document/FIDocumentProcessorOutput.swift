//
//  FIDocumentProcessorOutput.swift
//  Flow Inspector
//
//  Created by Volodymyr Pavliukevych on 8/21/18.
//  Copyright © 2018 Octadero. All rights reserved.
//

import Foundation

extension FIDocument: ProcessorOutput {
    
    func binFileURL() throws -> URL {
        guard let binFilePth = self.model.binFilePath else { throw FIDocumentError.canNotComputeBinFileURL }
        guard let url = URL(string: binFilePth) else { throw FIDocumentError.canNotComputeBinFileURL }
        return url
    }
    
    func dsymFileURL() throws -> URL {
        guard let dSYMFilePath = self.model.dSYMFilePath else { throw FIDocumentError.canNotComputeDSYMFileURL }
        guard let url = URL(string: dSYMFilePath) else { throw FIDocumentError.canNotComputeDSYMFileURL }
        return url
    }
    
    func sourceFileURL() throws -> URL {
        guard let sourceFilePath = self.model.sourceFilePath else { throw FIDocumentError.canNotComputeBinFileURL }
        guard let url = URL(string: sourceFilePath) else { throw FIDocumentError.canNotComputeSourceFileURL }
        return url
    }
    
    func outputStreamReceived(_ string: String) {
        self.debugViewInput?.insertOutput(string)
    }
    
    func errorStreamReceived(_ string: String) {
        self.debugViewInput?.insertError(string)
    }
    
}
