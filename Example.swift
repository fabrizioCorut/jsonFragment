//
//  ChildFragment.swift
//  Example
//
//  Created by Coruț Fabrizio on 18.03.2021.
//  Copyright © 2021 Shortcut AS. All rights reserved.
//

import XCTest
import Foundation

// swiftlint:disable vertical_parameter_alignment
final class ChildJSONFragment: ModelJSONFragment<ChildJSONFragment.Keys> {
	enum Keys: String {
		case birthDate, gender
	}

	convenience init( birthDate: String? = "1999-01-14T00:00:00",
					  gender: String? = MemberModel.Gender.female.rawValue ) {
		self.init( referenceValues: [ .birthDate: birthDate, .gender: gender ] )
	}

	override func compareCurrentFragment( to model: Any ) {
		// Do not fail if the provided model is not ChildModel, it might be useed from the MemberModel.
		guard let model = model as? ChildModel else { return }
		if let dateString = referenceValues[.birthDate] as? String, let birthDate = DateFormatter.date( fromRFC3339String: dateString ) {
			XCTAssertEqual( birthDate, model.birthDate )
		} else {
			XCTFail( "Date formatting has changed. Update the test!" )
		}
		if let genderString = referenceValues[.gender] as? String, let gender = MemberModel.Gender( rawValue: genderString ) {
			XCTAssertEqual( genderString, model.rawGender )
			XCTAssertEqual( gender, model.gender )
		} else {
			// If we do not provide a valid gender the model will default to .undefined.
			XCTAssertEqual( model.gender, .undefined )
		}
	}
}
