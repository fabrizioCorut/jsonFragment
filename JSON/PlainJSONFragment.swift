//
//  PlainJSONFragment.swift
//  jsonFragment
//
//  Created by Coruț Fabrizio on 18.03.2021.
//  Copyright © 2021 Shortcut AS. All rights reserved.
//

import Foundation

/// The most simple and plain implementation of the `JSONFragment` protocol. It allows you to create your own custom `fragment value`
/// or provide a key and a value for which this is done automatically for you.
struct PlainJSONFragment: JSONFragment {

	private enum GenericKey: RawRepresentable, Hashable {
		case any( key: String )

		// MARK: - RawRepresentable implementation.

		init?( rawValue: String ) { self = .any( key: rawValue ) }

		var rawValue: String {
			switch self {
			case .any( let key ):
				return key
			}
		}
	}

	/// Starting point of composing models into JSONs.
	static let empty = PlainJSONFragment( jsonValue: .init(), fragments: [] )

	// MARK: - JSONFragment implementation

	let value: String
	let fragments: [JSONFragment]

	// MARK: - Init.

	/// Creates a `JSONFragment` with a custom, by hand written value of it. It is expected to be a valid `JSON fragment`, not a `JSON` value.
	/// - Parameters:
	///   - value: Custom `JSONFragment` valid value.
	///   - fragments: Other fragments used to have configured the custom value.
	public init( jsonValue: String, fragments: [JSONFragment] ) {
		self.value = jsonValue
		self.fragments = fragments
	}

	/// Creates a `JSONFragment` from with a single entry which will be : `key: value`.
	/// - Parameters:
	///   - key: The key of the fragment.
	///   - fragment: The value found at the key. Should be a valid value `(Int, Bool, Double, etc.)` or a valid JSON value `({..}`, `[..]`).
	public init( key: String, value: JSONFragment ) {
		// Transform into a keyed dictionary so we reuse `jsonFragmentValue`.
		let jsonDict: [GenericKey: Any?] = [ .any(key: key): value ]
		self.value = jsonDict.jsonFragmentValue
		self.fragments = [value]
	}
}
