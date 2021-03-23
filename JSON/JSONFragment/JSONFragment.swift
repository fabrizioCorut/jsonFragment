//
//  JSONFragment.swift
//  jsonFragment
//
//  Created by Coruț Fabrizio on 17.03.2021.
//  Copyright © 2021 Shortcut AS. All rights reserved.
//

import Foundation

/// Should represent an object which stands for a fragment part of a JSON. Fragment = any valid JSON format without the encolsing accolates (`{` `}`) or square brackets (`[` `]`).
public protocol JSONFragment {

	/// JSON fragment `string representation`.
	var value: String { get }

	/// All the `fragments` used to compose the current fragment.
	var fragments: [JSONFragment] { get }

	/// Should compare the model against the data used to configure and create the `JSON` fragment.
	/// Does not compare the `fragments` recursively. For that, use `JSONFragment.compare(to:)`
	/// - Parameter model: The model created from the composed `JSON` fragments.
	func compareCurrentFragment( to model: Any )
}

public extension JSONFragment {

	/// `utf8` representation of the `.value`.
	var data: Data {
		.init( value.utf8 )
	}

	// MARK: - Comparison

	/// Iteratively goes through the `fragments` and provides the `model` for comparison. Also compared to the current `fragment`.
	/// - Parameter model: The model created from the composed `JSON` fragments.
	func compare( to model: Any ) {
		// Compare the current fragment.
		compareCurrentFragment( to: model )

		// Recursively compare the component fragments as well.
		fragments.forEach { $0.compare( to: model ) }
	}

	// Default implementation so we don't have to implement it redundantly for
	// implementations which are mere containers. e.g. `JSONComposer`.
	func compareCurrentFragment( to model: Any ) { }
}
