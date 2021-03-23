//
//  ModelJSONFragment.swift
//  jsonFragment
//
//  Created by Coruț Fabrizio on 18.03.2021.
//  Copyright © 2021 Shortcut AS. All rights reserved.
//

import Foundation

/// Generic class used to reduce the boilerplate of code used when creating custom `JSONFragments` which resemble actual fragments of concrete models.
/// As opposed to `PlainJSONFragment`, this allso allows the inverse connection to the data that is used in fragment creation, thus, allowing
/// testability of it vs. the actual resulted model.
/// Example of usage: Each should create ane `enum X: String` so that referencing keys from the `referenceValues` dictionary is easier.
public class ModelJSONFragment<T: RawRepresentable & Hashable>: JSONFragment where T.RawValue == String {

	// MARK: - JSONFragment implementation

	public let value: String
	public let fragments: [JSONFragment]

	// MARK: - Public interface.

	/// Stores all the values that were used to configure and create the `JSONComposableFragment.value`.
	/// Used for comparison against the real model.
	public let referenceValues: [T: Any?]

	// MARK: - Init.

	public convenience init( referenceValues: [T: Any?], fragments: [JSONFragment] = [] ) {
		self.init( value: referenceValues.jsonFragmentValue, referenceValues: referenceValues, fragments: fragments )
	}

	public init( value: String, referenceValues: [T: Any?], fragments: [JSONFragment] = [] ) {
		self.value = value
		self.referenceValues = referenceValues
		self.fragments = fragments
	}

	// Implement otherwise the subclass, even if it implements the method, it won't get recognized.
	public func compareCurrentFragment( to model: Any ) {
		fatalError( "Implement me for a custom comparison." )
	}
}
