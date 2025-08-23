# Document Parsing Architecture

This document outlines the enhanced document parsing system that handles both PDF and image files using different approaches optimized for each file type.

## Architecture Overview

### 🏗️ **Service Architecture**

```
UnifiedDocumentParsingService
├── OpenAIPDFParsingService (PDF → File Upload → File Search + Structured Parsing)
└── OpenAIDocumentService (Direct Vision for Images)
```

### 📁 **Supported File Types**

| File Type | Extension | Parsing Method | Description |
|-----------|-----------|----------------|-------------|
| **PDF** | `.pdf` | File Upload + Search | Uploads PDF to OpenAI, creates vector store, uses file search with structured parsing |
| **Images** | `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.heic`, `.heif` | Direct Vision | Direct analysis using OpenAI vision models |

## Implementation Details

### 📄 **PDF Parsing Flow**

1. **File Upload**: Upload PDF directly to OpenAI Files API
2. **Vector Store Creation**: Create temporary vector store for document processing
3. **File Processing**: Add file to vector store and wait for processing completion
4. **Structured Search**: Use file search tool with structured JSON schema
5. **Content Extraction**: Extract structured data using OpenAI's parsing capabilities
6. **Cleanup**: Remove temporary files and vector stores

### 📱 **Image Parsing Flow**

1. **Direct Processing**: Send image directly to OpenAI Vision API
2. **Base64 Encoding**: Convert image data to base64 for API transmission
3. **Structured Output**: Use JSON schema for consistent parsing results

## Services Breakdown

### `UnifiedDocumentParsingService`
- **Purpose**: Main orchestrator that routes documents to appropriate parsers
- **File Type Detection**: Automatic routing based on file extension
- **Convenience Methods**: `parsePrescription()`, `parseBloodReport()`
- **Support Checking**: `isFileTypeSupported()`, `getParsingMethod()`

### `OpenAIPDFParsingService`
- **Direct PDF Upload**: Uses OpenAI Files API for native PDF support
- **Vector Store Management**: Creates temporary vector stores for document processing
- **File Search Integration**: Leverages OpenAI's file search capabilities
- **Structured Parsing**: Uses JSON schema for consistent data extraction
- **Resource Cleanup**: Automatically removes temporary files and vector stores

### `OpenAIDocumentService` (Modified)
- **Image Only**: Now restricted to image files only
- **Vision Model**: Uses GPT-4o with vision capabilities
- **Structured Output**: JSON schema for consistent results
- **Error Handling**: Clear error messages for unsupported file types

## Usage Examples

### Basic Usage
```swift
let parsingService = UnifiedDocumentParsingService(apiKey: "your-api-key")

// Parse any supported document type
let prescription = try await parsingService.parsePrescription(from: documentURL)
let bloodReport = try await parsingService.parseBloodReport(from: documentURL)
```

### Integration with DocumentProcessingService
```swift
// Use the unified service for all document types
let processingService = DocumentProcessingService.createWithUnifiedParsing(
    apiKey: "your-api-key",
    modelContext: modelContext
)
```

### File Type Checking
```swift
if parsingService.isFileTypeSupported(documentURL) {
    let method = parsingService.getParsingMethod(for: documentURL)
    print("Will use: \(method?.description ?? "unknown")")
}
```

## Error Handling

### PDF-Specific Errors
- `OpenAIServiceError.uploadFailed`: PDF file upload to OpenAI failed
- `OpenAIServiceError.parseFailed`: Vector store creation or file processing failed
- `OpenAIServiceError.networkError`: Network connectivity issues during upload or processing

### OpenAI Service Errors
- `OpenAIServiceError.unsupportedFileType`: File type not supported for direct vision
- `OpenAIServiceError.parseFailed`: Vision model parsing failed
- `OpenAIServiceError.networkError`: Network connectivity issues

### Unified Service Errors
- `UnifiedParsingError.unsupportedFileType`: File extension not supported

## Configuration Options

### PDF Parsing Configuration
```swift
// Parse PDF using direct upload (no additional configuration needed)
let result = try await pdfService.parsePDFDocument(
    from: url,
    as: ParsedPrescription.self
)
```

### File Upload Settings
- **Maximum File Size**: 512 MB per file (OpenAI limit)
- **Processing Timeout**: 60 seconds for file processing
- **Automatic Cleanup**: Temporary resources removed after parsing

## Performance Considerations

### PDF Processing
- **Memory Usage**: Minimal - file is uploaded directly to OpenAI
- **Processing Time**: Single upload + processing time on OpenAI's servers
- **API Calls**: Upload + vector store creation + file search (3-4 calls total)

### Image Processing
- **Memory Usage**: Minimal - direct processing
- **Processing Time**: Single API call
- **API Calls**: One OpenAI call per document

## Migration Guide

### From OpenAI-Only Service
```swift
// Old approach
let openAIService = OpenAIDocumentService(apiKey: apiKey)
// This would fail for PDFs

// New approach
let unifiedService = UnifiedDocumentParsingService(apiKey: apiKey)
// Handles both PDFs and images automatically
```

### Updating DocumentProcessingService
```swift
// Replace factory method call
let service = DocumentProcessingService.createWithUnifiedParsing(
    apiKey: apiKey,
    modelContext: modelContext
)
```

## Future Enhancements

1. **Vector Store Reuse**: Cache vector stores for similar documents
2. **Batch Processing**: Process multiple documents in parallel
3. **Custom Metadata**: Add metadata to uploaded files for better search
4. **Alternative Models**: Support for different OpenAI models
5. **Fallback Strategies**: Text extraction fallback for problematic PDFs