//
//  Dictionary+JSON.swift
//  jsonFragment
//
//  Created by Coruț Fabrizio on 18.03.2021.
//  Copyright © 2021 Shortcut AS. All rights reserved.
//

import Foundation

public extension Dictionary where Key: RawRepresentable, Key.RawValue == String, Value == Any? {

	/// Representation of the key-values, transformed into valid JSON fragment values.
	var jsonFragmentValue: String {
		reduce( "" ) { acc, keyValue -> String in
			guard let actualValue = keyValue.value else { return acc }
			let stringValue: String
			switch actualValue {
			case is Int, is Double, is Bool:
				stringValue = "\(actualValue)"

			case is String:
				stringValue = "\"\(actualValue)\""

			case is JSONFragment:
				stringValue = "\((actualValue as! JSONFragment).value)" // We're checking the type beforehand. -FAIO

			default:
				NSLog( "Ignoring: \(keyValue)." )
				return acc
			}
			return acc + (acc.isEmpty ? "" : ", ") + "\"\(keyValue.0.rawValue)\": \(stringValue)"
		}
	}

	/// Creates `JSONFragment` value from only a subset of the keys in the dictionary, if present.
	/// - Parameter include: Keys that should be included.
	func partialJSONFragmentValue( include: Set<Key> ) -> String {
		filter { include.contains( $0.key ) }
			.jsonFragmentValue
	}
}
