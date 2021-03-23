# jsonFragment

In order to build up models for _parsing unit tests_ which is usually needed when we refactor models, we want to make sure that we can still correctly and backwards compatible parse models. For this, but not only, we need a way to build up models from the ground up in unit tests, which usually ends up in building the JSON and creating the model from it.

My idea was to create some type safe building blocks for creating the model `JSON` and as well, provide through the same blocks a way to automatically verify that the data in the model is the one that we've created the `JSON` with. If I succeeded in doing this, you be the judge of.

# JSONFragment

```swift
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
```

I've used the **Composite Pattern** for this part and it should both represent: 
- a basic building block (fragment: _A JSON fragment is a JSON that does not have an Object or an Array as the root._);
```
"some_key": 3,
"other_key": "abd",
"array_key": [ .. ],
"json_key": { .. }

any subset of the set of examples from above is a valid JSON fragment
```
- a valid JSON as well;
```
{
  "some_key": 3,
  "other_key": "abd",
  "array_key": [ .. ],
  "json_key": { .. }
}
```

Created it as a `protocol` instead of a concrete class so we can allow different customizations and custom implementations, based on the need, as we will see further down. 
There are some default implementations: 

```swift
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

# Used to more easily compose fragments.

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

# Used to more easily transform fragments to valid JSON values

/// Transforms the current `JSONFragment` into a valid `JSON`.
func toJSON() -> JSONFragment {
	JSONComposer( fragment: self, enclosing: .accolades )
}

/// Transforms the current `JSONFragment` into a valid `JSON array`.
func toJSONArray() -> JSONFragment {
	JSONComposer( fragment: self, enclosing: .squareBrackets )
}
```

Now, why would we need `fragments: [JSONFragment]`? This is because we need to iterate recursively through the building blocks when using the `compare(to:)` method in order to see that the data with which the JSON has been composed is actually the data that the model has.
This brings us back to the discussion about the two way connection between the `JSONFragment` and the `model`: we create the model by using the `JSONFragment` but the `JSONFragment` needs the `model` in order to validate the data.
Hence, if we have a `JSONFragment` which is composed by multiple fragments, arrays, JSONs, we want to start from the base `JSONFragment` but we also want to check the other building blocks that have been used to create it so we don't have to keep references to all of them:
```swift 
e.g. 
let finalJSON = EmptyFragment()
   .byAdding(FragmentA)
   .byAdding(FragmentB)
   .byAdding(FragmentC)
   .toJSONArray()
   .byAdding(FragmentD)
   .toJSON()
```
instead of havign to keep a reference to all the fragments (A, B, C, D), the `finalJSON` will handle that for us and the comparison will go down recursively.

# JSONComposer

Is a special concrete implementation of a `JSONFragment` which transforms fragments into valid JSONs. e.g. adds accolades `{ .. }` or square brackets for arrays: `[ .. ]`. It has no other functionality and serves the purpose of being a construction aid.

# PlainJSONFragment

Is the most basic, yet the most customizable concrete implementation of `JSONFragment`. It can be instantiated using:
- a `key` and a `value`, for a single lined JSON fragment;
- but at the same time it can be instantiated using a `jsonValue: String`; this functionality, even though it defeates the whole purpose of having composable building blocks, at some point you might not want to create concrete `JSONFragment` implementations for all of the models and sub-models of a model: `e.g. MemberAssociatedStoreJSONFragment`. This functionality allows you to create in-place `JSONFragments`;

# ModelJSONFragment
```swift
public class ModelJSONFragment<T: RawRepresentable & Hashable>: JSONFragment where T.RawValue == String {
```

Is thought of being the building block for testing models: The `T` suggests that we should have a type-safe way of accessing and referencing model fields. This is also used with the:
```swift
/// Stores all the values that were used to configure and create the `JSONComposableFragment.value`.
/// Used for comparison against the real model.
public let referenceValues: [T: Any?]
```
whose purpose is to test the values with which the `JSONFragment` was created against the model. We also use the `referenceValues` to create valid `JSONFragment` string representations.
e.g.
```swift
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
		guard let model = model as? Pokemon else { return }
		XCTAssertEqual(referenceValues[.baseType] as? String, model.baseType.rawValue)
		XCTAssertEqual(referenceValues[.name] as? String, model.name)
		XCTAssertEqual(referenceValues[.pokedexIndex] as? Int, model.pokedexIndex)
	}
}
```

So, `ModelJSONFragment` binds the whole concepts under the same roof: `JSONFragment` as itself represents one, type safe representation of the fields: `enum Keys` and being able to test the values with which the JSON has been created against the actual model.

# Conclusion

The main idea behind the fragments is that we can build type-safe classes/ structs that mimic the model/ smaller parts of the model. 
Based on them we can build the `JSON representation` and we can thus avoid having to copy-paste entire `String JSONs` and insert `%@` modifiers in order to customize data.
We have a high level of flexibility from composition: we can easily `include` or `exclude` entire parameters/ fragments without having to create new `String JSONs` representations/ a new JSON file which have/ do not have those parameters/ fragments included. 

**e.g.** for a model which has a parameter an enum. We want to be able to test all the possible enum cases. Instead of creating a new JSON for each of the enum case, we'll simply create a new JSONFragment, composable, for each of it: `SomeEnum.allCases.map { CaseFragment(someCase: $0) }` and test the resulted JSONs in the same test function.
**e.g.** for nullable and non-nullable parameters. We can easily configure the fragments to include or not nullable or non-nullable parameters to test that the parsing succeeds without the `nullable parameters` and the expected default values are used instead OR that the parsing fails without the `non-nullable parameters`.

# Known drawbacks

- we have to cast the `model` all the time when we compare. If we want to test the same model in different scenarios, we can't really do that;
- arrays of simple values: e.g. ["fire", "ice", "fighting"];
- testing the actual values in the arrays, if each entry in the array is a JSON, we'll pass in the _whole_ module when comparing, thus, we have to manually search for the entry in the array to find the one to match the current `JSONFragment`; This ties back to the first drawback;
