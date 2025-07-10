import Foundation

var greeting = "```json\n{\n  \"dateIssued\": \"2025-05-27T15:18:00Z\",\n  \"doctorName\": \"Dr. Ravi Sankar Erukulapati\",\n  \"facilityName\": \"Apollo Hospitals Jubilee Hills\",\n  \"followUpDate\": \"2025-06-10T15:18:00Z\",\n  \"followUpTests\": [\n    \"SODIUM\",\n    \"POTASSIUM\", \n    \"CREATININE\",\n    \"TESTOSTERONE TROUGH LEVELS\",\n    \"FREE T4\",\n    \"FREE T3\",\n    \"LFTS\"\n  ],\n  \"notes\": \"see 17-5-2025 physical consult prescription, please. note- on att as per pulmonologist for uveitis- tb test positive. plan: counselled. sick day rules.\",\n  \"medications\": [\n    {\n      \"id\": \"550e8400-e29b-41d4-a716-446655440001\",\n      \"name\": \"HISONE\",\n      \"frequency\": [\n        {\n          \"mealTime\": \"breakfast\",\n          \"timing\": null,\n          \"dosage\": \"10 MG\"\n        },\n        {\n          \"mealTime\": \"lunch\", \n          \"timing\": null,\n          \"dosage\": \"5 MG\"\n        },\n        {\n          \"mealTime\": \"dinner\",\n          \"timing\": null,\n          \"dosage\": \"5 MG\"\n        }\n      ],\n      \"numberOfDays\": 14,\n      \"dosage\": \"10 MG AT 7 AM, 5 MG AT 12 NOON AND 5 MG AT 5 PM\",\n      \"instructions\": \"Increase TAB HISONE TO 10 MG AT 7 AM, 5 MG AT 12 NOON AND 5 MG AT 5 PM\"\n    },\n    {\n      \"id\": \"550e8400-e29b-41d4-a716-446655440002\",\n      \"name\": \"SUSTANON INJECTION\",\n      \"frequency\": [],\n      \"numberOfDays\": 14,\n      \"dosage\": null,\n      \"instructions\": \"AS PER MY 17-5-2025 physical PRESCRIPTION, PLEASE\"\n    },\n    {\n      \"id\": \"550e8400-e29b-41d4-a716-446655440003\",\n      \"name\": \"THYRONORM\",\n      \"frequency\": [\n        {\n          \"mealTime\": \"breakfast\",\n          \"timing\": \"before\",\n          \"dosage\": \"125 MICROGRAMS\"\n        }\n      ],\n      \"numberOfDays\": 14,\n      \"dosage\": \"125 MICROGRAMS\",\n      \"instructions\": \"CONTINUE TAB THYRONORM 125 MICROGRAMS DAILY EMPTY STOMACH\"\n    }\n  ]\n}\n```"

struct ParsedPrescription: Codable {
    
    struct Medication: Codable {
        var id: UUID
        var name: String
        var frequency: [MedicationSchedule]
        var numberOfDays: Int
        var dosage: String?
        var instructions: String?
    }
    
    // Metadata
    var dateIssued: Date
    var doctorName: String?
    var facilityName: String?
    
    var followUpDate: Date?
    var followUpTests: [String]
    
    var notes: String?
    
    var medications: [Medication]
    
}

struct MedicationSchedule: Codable {
    
    enum MealTime: String, Codable, CaseIterable {
        case breakfast, lunch, dinner, bedtime
    }
    
    enum MedicationTime: String, Codable, CaseIterable {
        case before, after
    }
    
    let mealTime: MealTime
    let timing: MedicationTime? // before/after
    let dosage: String?
}



func processDocument(response: String) -> String {
    var new = response.replacingOccurrences(of: "\n", with: "")
        .replacingOccurrences(of: "```", with: "")
        .replacingOccurrences(of: "json", with: "")
    return new
}

func decodeDocument(from jsonString: String) throws -> ParsedPrescription? {
    // Parse the JSON response
    let jsonStringStr = processDocument(response: jsonString)
    guard let jsonData = jsonStringStr.data(using: .utf8) else {
        return nil
    }
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let parsedObject = try decoder.decode(ParsedPrescription.self, from: jsonData)
    return parsedObject
}

do {
    dump(try decodeDocument(from: greeting))
} catch {
    print(error)
}

