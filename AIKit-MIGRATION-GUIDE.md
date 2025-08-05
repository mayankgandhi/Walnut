# AIKit Migration Guide

This guide helps you migrate from the existing in-app AI services to the new AIKit package.

## Overview

The AIKit package consolidates all AI-related functionality into a reusable, well-structured framework. This separation provides:

- **Better modularity**: AI functionality is separated from app-specific code
- **Reusability**: AIKit can be used in other projects
- **Cleaner architecture**: Clear separation between AI services and business logic  
- **Easier maintenance**: AI-related updates are contained within AIKit
- **Better testing**: AI functionality can be tested independently

## Package Structure

```
AIKit/
├── Sources/AIKit/
│   ├── Core/
│   │   ├── Models.swift              # Shared data models (ParsedPrescription, etc.)
│   │   ├── Protocols.swift           # Service protocols
│   │   └── UnifiedDocumentParsingService.swift
│   ├── OpenAI/
│   │   ├── OpenAIModels.swift        # OpenAI-specific models and errors
│   │   ├── OpenAINetworkClient.swift # HTTP client for OpenAI API
│   │   ├── OpenAIDocumentParser.swift # Document parsing logic
│   │   └── OpenAIDocumentService.swift # Main OpenAI service
│   ├── Utilities/
│   │   ├── MimeTypeResolver.swift    # File type utilities
│   │   └── MultipartFormBuilder.swift # HTTP form data utilities
│   ├── AIKit.swift                   # Main module file
│   └── AIKitPublic.swift            # Public API exports
└── Tests/
    └── AIKitTests.swift
```

## Migration Steps

### 1. Import AIKit

Add the import statement to files that use AI services:

```swift
import AIKit
```

### 2. Update Service Creation

**Before (using local services):**
```swift
// Old approach
let processingService = DocumentProcessingService.createWithUnifiedParsing(
    apiKey: openAIKey,
    modelContext: modelContext
)
```

**After (using AIKit):**
```swift
// New approach using AIKit
import AIKit

let aiService = AIKitFactory.createUnifiedService(openAIAPIKey: openAIKey)

// Or use configuration approach
let config = AIKitConfiguration(openAIAPIKey: openAIKey)
let aiService = try config.createUnifiedService()
```

### 3. Update DocumentProcessingService Integration

The DocumentProcessingService in the main app needs to be updated to work with AIKit services. Since AIKit services conform to `AIDocumentServiceProtocol`, they can be used directly:

**Updated DocumentProcessingService factory method:**
```swift
// In DocumentProcessingService.swift
extension DocumentProcessingService {
    /// Creates a DocumentProcessingService using AIKit's unified parsing
    static func createWithAIKit(
        openAIAPIKey: String,
        modelContext: ModelContext
    ) -> DocumentProcessingService {
        let aiService = AIKitFactory.createUnifiedService(openAIAPIKey: openAIAPIKey)
        let fileService = DefaultFilePreparationService()
        let repository = DefaultDocumentRepository(modelContext: modelContext)
        
        return DocumentProcessingService(
            aiService: aiService,
            fileService: fileService,
            repository: repository
        )
    }
}
```

### 4. Update Model Imports

**Before:**
```swift
// Models were defined locally in the app
import Foundation
// Local ParsedPrescription, ParsedBloodReport, etc.
```

**After:**
```swift
// Models come from AIKit
import AIKit

// Use AIKit models directly
let prescription: ParsedPrescription = ...
let bloodReport: ParsedBloodReport = ...
```

### 5. Update View Usage

**Before (in SpecializedDocumentPickers.swift):**
```swift
.task {
    if processingService == nil {
        let apiKey = openAIKey
        processingService = DocumentProcessingService.createWithUnifiedParsing(
            apiKey: apiKey,
            modelContext: modelContext
        )
    }
}
```

**After:**
```swift
import AIKit

.task {
    if processingService == nil {
        processingService = DocumentProcessingService.createWithAIKit(
            openAIAPIKey: openAIKey,
            modelContext: modelContext
        )
    }
}
```

### 6. Direct Service Usage

If you need to use AIKit services directly (without DocumentProcessingService):

```swift
import AIKit

class MyDocumentHandler {
    private let aiService: UnifiedDocumentParsingService
    
    init(openAIAPIKey: String) {
        self.aiService = AIKitFactory.createUnifiedService(openAIAPIKey: openAIAPIKey)
    }
    
    func parsePrescription(from url: URL) async throws -> ParsedPrescription {
        return try await aiService.parsePrescription(from: url)
    }
    
    func parseBloodReport(from url: URL) async throws -> ParsedBloodReport {
        return try await aiService.parseBloodReport(from: url)
    }
}
```

## Files to Update

### Priority 1: Core Integration Files
1. `/Users/mayankgandhi/Apps/Walnut/Walnut/Sources/Features/DocumentParsing/DocumentProcessor/DocumentProcessingService.swift`
   - Add AIKit import
   - Add factory method using AIKit services
   - Update protocol extensions if needed

2. `/Users/mayankgandhi/Apps/Walnut/Walnut/Sources/Features/DocumentParsing/DocumentPicker/SpecializedDocumentPickers.swift`
   - Replace service creation calls with AIKit factory methods

### Priority 2: Model Usage Files  
3. Any files that import or use:
   - `ParsedPrescription` 
   - `ParsedBloodReport`
   - `MedicationSchedule`
   - Should add `import AIKit`

### Priority 3: Files to Remove/Deprecate
Once migration is complete, these files can be removed:
- `/Users/mayankgandhi/Apps/Walnut/Walnut/Sources/Features/DocumentParsing/OpenAIServices/*`
- `/Users/mayankgandhi/Apps/Walnut/Walnut/Sources/Features/DocumentParsing/ClaudeServices/*`
- `/Users/mayankgandhi/Apps/Walnut/Walnut/Sources/Features/DocumentParsing/UnifiedDocumentParsingService.swift`
- `/Users/mayankgandhi/Apps/Walnut/Walnut/Sources/Features/DocumentParsing/Utilities/*`
- `/Users/mayankgandhi/Apps/Walnut/Walnut/Sources/Features/DocumentParsing/Key.swift` (move keys to secure storage)

## API Key Management

**Security Note:** The current `Key.swift` file contains hardcoded API keys, which is not secure. Consider:

1. **Environment Variables:**
```swift
let openAIKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
```

2. **Secure Keychain Storage:**
```swift
// Store in keychain and retrieve securely
```

3. **Configuration File (not committed to git):**
```swift
// Load from a local config file that's gitignored
```

## Benefits After Migration

1. **Cleaner Codebase**: AI functionality is separated from app logic
2. **Better Testing**: AIKit can be tested independently
3. **Reusability**: AIKit can be used in other projects or extensions
4. **Easier Updates**: AI service updates are contained within the package
5. **Better Documentation**: AI functionality is well-documented within the package

## Validation Steps

After migration, verify:

1. **Build Success**: The project builds without errors
2. **Document Parsing**: Prescription and blood report parsing still works
3. **Error Handling**: Error messages are displayed correctly
4. **File Type Support**: Only supported file types are accepted
5. **Performance**: No degradation in parsing performance

## Rollback Plan

If issues arise, you can temporarily revert by:
1. Commenting out AIKit imports
2. Restoring the original service creation code
3. Re-enabling the local AI service files

The original files will remain in place until the migration is fully validated.