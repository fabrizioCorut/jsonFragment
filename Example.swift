//
//  ChildFragment.swift
//  Example
//
//  Created by Coruț Fabrizio on 18.03.2021.
//  Copyright © 2021 Shortcut AS. All rights reserved.
//

import XCTest
import Foundation

struct Pokemon: Codable {

	enum `Type`: String, CaseIterable {
		case normal
		case fire
		case fighting
		case water
		case flying
		case grass
		case poison
		case electric
		case ground
		case psychic
		case rock
		case ice
		case bug // NO, not an actual bug in the code.
		case dragon
		case ghost
		case dark
		case steel
		case fairy
		/// If none of the above ones are provided.
		case undefined
	}

	/// The core strength of the `Pokemon`.
	let baseType: `Type`

	/// Every `Pokemon` must have a name.
	let name: String

	/// `nil` if the `Pokemon` has not been seen before.
	let pokedexIndex: Int?
}

final class PokemonJSONFragment: ModelJSONFragment<PokemonJSONFragment.Keys> {
	enum Keys: String {
		case baseType, name, pokedexIndex
	}

	convenience init(baseType: String? = Pokemon.`Type`.fire.rawValue,
					 name: String? = "Charizard",
					 pokedexIndex: Int? = 6) {
		self.init(referenceValues: [ .baseType: baseType, .name: name, .pokedexIndex: pokedexIndex ])
	}

	override func compareCurrentFragment(to model: Any) {
		// Do not fail if the provided model is not ChildModel, it might be useed from the MemberModel.
		guard let model = model as? Pokemon else { return }
		XCTAssertEqual(referenceValues[.baseType] as? String, model.baseType.rawValue)
		XCTAssertEqual(referenceValues[.name] as? String, model.name)
		XCTAssertEqual(referenceValues[.pokedexIndex] as? Int, model.pokedexIndex)
	}
}

final class PokemonParsingTests: XCTestCase {

	func testDefaultValues() throws {
		let jsonRepresentation = PokemonJSONFragment().toJSON()
		let model = try JSONDecoder().decode(Pokemon.self, from: jsonRepresentation.data)
		jsonRepresentation.compare(to: model)
	}

	func testBaseTypesValues() throws {
		let decoder = JSONDecoder()
		try Pokemon.`Type`.allCases.forEach {
			let jsonRepresentation = PokemonJSONFragment(baseType: $0.rawValue)
				.toJSON()
			let model = try decoder.decode(Pokemon.self, from: jsonRepresentation.data)
			jsonRepresentation.compare(to: model)
		}
	}

	func testNonNullable() throws {
		let decoder = JSONDecoder()
		try [PokemonJSONFragment(baseType: nil), PokemonJSONFragment(name: nil)]
			.lazy
			.map { $0.toJSON() }
			.forEach {
				let model = try? decoder.decode(Pokemon.self, from: $0.data)
				XCTAssertNil(model)
			}
	}

	func testNullable() throws {
		let jsonRepresentation = PokemonJSONFragment(pokedexIndex: nil).toJSON()
		let model = try JSONDecoder().decode(Pokemon.self, from: jsonRepresentation.data)
		jsonRepresentation.compare(to: model)
	}
}
