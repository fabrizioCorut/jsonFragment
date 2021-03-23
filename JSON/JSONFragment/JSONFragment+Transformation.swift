//
//  JSONFragment+Transformation.swift
//  jsonFragment
//
//  Created by Coruț Fabrizio on 19.03.2021.
//  Copyright © 2021 Shortcut AS. All rights reserved.
//

import Foundation

public extension JSONFragment {

	/// Transforms the current `JSONFragment` into a valid `JSON`.
	func toJSON() -> JSONFragment {
		JSONComposer( fragment: self, enclosing: .accolades )
	}

	/// Transforms the current `JSONFragment` into a valid `JSON array`.
	func toJSONArray() -> JSONFragment {
		JSONComposer( fragment: self, enclosing: .squareBrackets )
	}
}

public extension Array where Element == JSONFragment {

	/// Binds the fragments and transforms them into a valid `JSON`.
	func toJSON() -> JSONFragment {
		JSONComposer( fragments: self, enclosing: .accolades )
	}

	/// Binds the fragments and transforms them into a valid `JSON array`.
	/// It assumes that each `JSONFragment` is a valid `JSON` value.
	func toJSONArray() -> JSONFragment {
		JSONComposer( fragments: self, enclosing: .squareBrackets )
	}
}
