//
//  JSONComposer.swift
//  jsonFragment
//
//  Created by Coruț Fabrizio on 18.03.2021.
//  Copyright © 2021 Shortcut AS. All rights reserved.
//

import Foundation

/// Simple binder of JSON fragments. Adds the missing enclosing accolades or square brackets from `JSONFragments`.
public struct JSONComposer: JSONFragment {

	public enum Enclosing {
		/// `{` value `}`
		case accolades

		/// `[` value `]`
		case squareBrackets

		var format: String {
			switch self {
			case .accolades:
				return "{ %@ }"

			case .squareBrackets:
				return "[ %@ ]"
			}
		}
	}

	// MARK: - JSONFragment implementation

	public let value: String
	public let fragments: [JSONFragment]

	// MARK: - Init.

	public init( fragments: [JSONFragment], enclosing: Enclosing ) {
		// Compose a bigger fragment out of the provided fragments and enclose them.
		let composedValue: JSONFragment = fragments.reduce( PlainJSONFragment.empty ) { acc, fragment in
			acc.byAdding( jsonComposable: fragment )
		}
		self.init( fragment: composedValue, enclosing: enclosing )
	}

	public init( fragment: JSONFragment, enclosing: Enclosing ) {
		// Keep the fragment as the value since the comparison search will be done recursively.
		// We don't want to miss any configurations on this fragment.
		self.fragments = [fragment]
		self.value = String( format: enclosing.format, fragment.value )
	}
}
