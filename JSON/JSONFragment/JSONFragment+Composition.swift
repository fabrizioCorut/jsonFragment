//
//  JSONFragment+Composition.swift
//  jsonFragment
//
//  Created by Coruț Fabrizio on 19.03.2021.
//  Copyright © 2021 Shortcut AS. All rights reserved.
//

import Foundation

public extension JSONFragment {

	/// Appends the value to the already built fragment.
	/// - Parameter jsonComposable: Should contain a new fragment.
	/// - Returns: A new instance containing the current values appended with the provided ones.
	func byAdding( jsonComposable: JSONFragment ) -> JSONFragment {
		// Make sure that the provided value is valid.
		guard !jsonComposable.value.isEmpty else { return self }
		// Make sure that we're valid.
		guard !value.isEmpty else { return PlainJSONFragment( jsonValue: jsonComposable.value, fragments: [jsonComposable] ) }
		// Both values are valid, put a comma between them.
		return PlainJSONFragment( jsonValue: value + "," + jsonComposable.value, fragments: fragments + [jsonComposable] )
	}
}
