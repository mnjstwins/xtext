package org.eclipse.xtext.example.domainmodel.tests

import com.google.inject.Inject
import org.eclipse.xtext.example.domainmodel.DomainmodelInjectorProvider
import org.eclipse.xtext.example.domainmodel.domainmodel.DomainModel
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.xbase.imports.ImportOrganizer
import org.junit.Ignore
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(DomainmodelInjectorProvider))
class OrganizeImportsTest {
	
	@Inject extension ParseHelper<DomainModel> 
	@Inject ImportOrganizer importOrganizer

	def protected assertIsOrganizedTo(CharSequence model, CharSequence expected) {
		val domainModel = parse(model.toString)
		val changes = importOrganizer.getOrganizedImportChanges(domainModel.eResource as XtextResource)
		val builder = new StringBuilder(model)
		for(it: changes.sortBy[offset].reverse)
			builder.replace(offset, offset + length, text)
		assertEquals(expected.toString, builder.toString)
	}

	@Test def testSimple() {
		'''
			package foo {
				entity Foo extends java.io.Serializable {}
			}
		'''.assertIsOrganizedTo('''
			import java.io.Serializable
			
			package foo {
				entity Foo extends Serializable {}
			}
		''')
	}

	@Test def testDefaultPackage() {
		'''
			entity Foo extends java.io.Serializable {}
		'''.assertIsOrganizedTo('''
			import java.io.Serializable

			entity Foo extends Serializable {}
		''')
	}

	@Test def testDefaultPackageLeadingWhitespace() {
		'''
			��
			   	
			entity Foo extends java.io.Serializable {}
		'''.assertIsOrganizedTo('''
			import java.io.Serializable

			entity Foo extends Serializable {}
		''')
	}

	@Test def testDefaultPackageWithJavaDoc() {
		'''
			/**
			 * some doc
			 */
			entity Foo extends java.io.Serializable {}
		'''.assertIsOrganizedTo('''
			import java.io.Serializable

			/**
			 * some doc
			 */
			entity Foo extends Serializable {}
		''')
	}

	@Test def testGetOrganizedImportSection_01() {
		'''
			import java.lang.String
			import java.util.List

			entity Foo {
			  op test(List<String> s) : void {}
			}
		'''.assertIsOrganizedTo('''
			import java.util.List

			entity Foo {
			  op test(List<String> s) : void {}
			}
		''')
	}

	@Test def testGetOrganizedImportSection_02() {
		'''
			import java.lang.String
			import java.util.List
			import java.util.List
			import java.util.List
			import java.lang.Integer

			entity Foo {
			  op test(List<String> s) : void {}
			}
		'''.assertIsOrganizedTo('''
			import java.util.List

			entity Foo {
			  op test(List<String> s) : void {}
			}
		''')
	}

	@Test def testInnerClasses_01() {
		'''
			entity Foo {
			  op test(org.eclipse.emf.ecore.resource.Resource$Factory a, org.eclipse.emf.ecore.resource.Resource$Factory$Registry b) : void {}
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.emf.ecore.resource.Resource

			entity Foo {
			  op test(Resource$Factory a, Resource$Factory$Registry b) : void {}
			}
		''')
	}

	@Test def testInnerClasses_02() {
		'''
			import org.eclipse.emf.ecore.resource.Resource
			import org.eclipse.emf.ecore.EPackage

			entity Foo {
			  op test() : void {
			    val x = Resource$Factory$Registry::INSTANCE
			    val y = EPackage$Registry::INSTANCE
			  }
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.emf.ecore.EPackage
			import org.eclipse.emf.ecore.resource.Resource

			entity Foo {
			  op test() : void {
			    val x = Resource$Factory$Registry::INSTANCE
			    val y = EPackage$Registry::INSTANCE
			  }
			}
		''')
	}

	@Test def testInnerClasses_03() {
		'''
			entity Foo {
			  op test() : boolean {
				 typeof(org.eclipse.emf.ecore.resource.Resource$Factory) == typeof(org.eclipse.emf.ecore.resource.Resource$Factory$Registry)
			  }
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.emf.ecore.resource.Resource

			entity Foo {
			  op test() : boolean {
				 typeof(Resource$Factory) == typeof(Resource$Factory$Registry)
			  }
			}
		''')
	}

	@Test def testInnerClasses_04() {
		'''
			import org.eclipse.emf.ecore.resource.Resource
			import org.eclipse.emf.ecore.EPackage

			entity Foo {
			  op test() : void {
			    typeof(Resource$Factory$Registry) == typeof(EPackage$Registry)
			  }
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.emf.ecore.EPackage
			import org.eclipse.emf.ecore.resource.Resource

			entity Foo {
			  op test() : void {
			    typeof(Resource$Factory$Registry) == typeof(EPackage$Registry)
			  }
			}
		''')
	}

	@Test def testInnerClasses_05() {
		'''
			import org.eclipse.emf.ecore.resource.Resource$Factory$Registry

			entity Foo {
			  op test() : void {
			    typeof(Registry)
			  }
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.emf.ecore.resource.Resource$Factory$Registry

			entity Foo {
			  op test() : void {
			    typeof(Registry)
			  }
			}
		''')
	}

	@Test def testNameClashSameFileWins_1() {
		'''
			package foo {
				entity Foo {
					x : java.lang.String
				}

				entity String {}
			}
		'''.assertIsOrganizedTo('''
			package foo {
				entity Foo {
					x : java.lang.String
				}

				entity String {}
			}
		''')
	}

	@Test def testNameClashSameFileWins() {
		'''
			package foo {
				entity Foo extends java.io.Serializable{}

				entity Serializable {}
			}
		'''.assertIsOrganizedTo('''
			package foo {
				entity Foo extends java.io.Serializable{}

				entity Serializable {}
			}
		''')
	}

	@Test def testNameClashOrder_01() {
		'''
			entity Foo {
			  op test(java.util.List<String> s) : java.awt.List {
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.awt.List

			entity Foo {
			  op test(java.util.List<String> s) : List {
			    return null
			  }
			}
		''')
	}

	@Test def testNameClashOrder_02() {
		'''
			entity Foo {
			  op test(java.awt.List<String> s) : java.util.List  {
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.util.List

			entity Foo {
			  op test(java.awt.List<String> s) : List  {
			    return null
			  }
			}
		''')
	}

	@Test def testNameClashMoreCommon() {
		'''
			entity Foo {
			  op test(java.awt.List s) : java.util.List<String> {
			  	new java.awt.List()
			    return null
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.awt.List

			entity Foo {
			  op test(List s) : java.util.List<String> {
			  	new List()
			    return null
			  }
			}
		''')
	}

	// TODO: activate when static imports are available 
	@Ignore@Test def testStaticImport_01() {
		'''
			import static java.util.Collections.*
			entity Foo {
			  op test(java.util.List<String> s) : void {
			  	shuffle(s)
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.util.List
			
			import static java.util.Collections.*

			entity Foo {
			  op test(List<String> s) : void {
			  	singleton(s)
			  }
			}
		''')
	}

	// TODO: activate when static extension imports are available 
	@Ignore@Test def testStaticImport_02() {
		'''
			import static extension java.util.Collections.*
			class Foo {
			  def void test(java.util.List<String> s) {
			    s.sort
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.util.List
			
			import static extension java.util.Collections.*

			entity Foo {
			  op test(List<String> s) : void {
			    s.sort
			  }
			}
		''')
	}
	
	@Test def testImplicitExtensions() {
		'''
			entity Foo {
			  op test(java.util.List<String> s) : void {
			    s.head
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.util.List

			entity Foo {
			  op test(List<String> s) : void {
			    s.head
			  }
			}
		''')
	}

	// TODO: activate when static extension imports are available 
	@Ignore@Test def testStaticExtensions() {
		'''
			import static extension java.util.Collections.*
			entity Foo {
			  op test() : void {
			    typeof(java.util.Collections).singleton
			  }
			}
		'''.assertIsOrganizedTo('''
			import java.util.Collections

			import static extension java.util.Collections.*

			entity Foo {
			  op test() : void {
			    typeof(Collections).singleton
			  }
			}
		''')
	}

	@Test def testInnerClassImport_01() {
		'''
			import java.util.Map$Entry
			
			package foo.bar {
				entity Foo {
				  op test() : Entry {
				    return null
				  }
				}
			}
		'''.assertIsOrganizedTo('''
			import java.util.Map$Entry

			package foo.bar {
				entity Foo {
				  op test() : Entry {
				    return null
				  }
				}
			}
		''')
	}

	@Test def testInnerClassImport_02() {
		'''
			import java.util.Map
			
			package foo.bar {
				entity Foo {
				  op test() : Map$Entry {
				    return null
				  }
				}
			}
		'''.assertIsOrganizedTo('''
			import java.util.Map

			package foo.bar {
				entity Foo {
				  op test() : Map$Entry {
				    return null
				  }
				}
			}
		''')
	}

	@Test def testInnerClassImport_03() {
		'''
			import java.util.Map$Entry

			package foo.bar {
				entity Foo {
				  op test() : Map$Entry {
				    return null
				  }
				}
			}
		'''.assertIsOrganizedTo('''
			import java.util.Map

			package foo.bar {
				entity Foo {
				  op test() : Map$Entry {
				    return null
				  }
				}
			}
		''')
	}

	@Test def testInnerClassImport_04() {
		'''
			import org.eclipse.emf.ecore.resource.Resource

			package foo.bar {
				entity Foo {
				  op test() : Resource$Factory$Descriptor {
				    return null
				  }
				}
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.emf.ecore.resource.Resource

			package foo.bar {
				entity Foo {
				  op test() : Resource$Factory$Descriptor {
				    return null
				  }
				}
			}
		''')
	}

	@Test def testInnerClassImport_05() {
		'''
			import org.eclipse.emf.ecore.resource.Resource$Factory$Descriptor

			package foo.bar {
				entity Foo {
				  op test() : Resource$Factory$Descriptor {
				    return null
				  }
				}
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.emf.ecore.resource.Resource

			package foo.bar {
				entity Foo {
				  op test() : Resource$Factory$Descriptor {
				    return null
				  }
				}
			}
		''')
	}

	@Test def testInnerClassImport_06() {
		'''
			import org.eclipse.emf.ecore.resource.Resource$Factory$Descriptor

			package foo.bar {
				entity Foo {
				  op test() : Descriptor {
				    return null
				  }
				}
			}
		'''.assertIsOrganizedTo('''
			import org.eclipse.emf.ecore.resource.Resource$Factory$Descriptor

			package foo.bar {
				entity Foo {
				  op test() : Descriptor {
				    return null
				  }
				}
			}
		''')
	}

	@Test def testFunctionTypes_afterResolve() {
		'''
			import java.util.Map$Entry

			package foo.bar {
				entity Foo {
				  op test() : (Entry)=>void {
				    return null
				  }
				}
			}
		'''.assertIsOrganizedTo('''
			import java.util.Map$Entry

			package foo.bar {
				entity Foo {
				  op test() : (Entry)=>void {
				    return null
				  }
				}
			}
		''')
	}

	// TODO: reenable once static imports are abvailable
	@Ignore@Test def testImport_PairOf() {
		'''
			import static org.eclipse.xtext.xbase.lib.Pair.*

			package foo.bar {
				entity Foo {
				  op test() : Object {
				    return of('', '')
				  }
				}
			}
		'''.assertIsOrganizedTo('''
			import static org.eclipse.xtext.xbase.lib.Pair.*

			package foo.bar {
				entity Foo {
				  op test() : Object {
				    return of('', '')
				  }
				}
			}
		''')
	}

	@Test def testArrayType() {
		'''
			import java.io.Serializable

			package foo.bar {
				entity Foo {
				  op test() : Serializable[][] {
				    return null
				  }
				}
			}
		'''.assertIsOrganizedTo('''
			import java.io.Serializable

			package foo.bar {
				entity Foo {
				  op test() : Serializable[][] {
				    return null
				  }
				}
			}
		''')
	}

	@Test def testClassWithSameName() {
		'''
			package foo.bar {
				entity Serializable {
				  clazz : Class<? extends java.io.Serializable>
				}
			}
		'''.assertIsOrganizedTo('''
			package foo.bar {
				entity Serializable {
				  clazz : Class<? extends java.io.Serializable>
				}
			}
		''')
	}

	@Test def testJavaDoc() {
		'''
			/**
			 * {@link java.util.List}
			 */
			entity Foo {}
		'''.assertIsOrganizedTo('''
			import java.util.List
			
			/**
			 * {@link List}
			 */
			entity Foo {}
		''')
	}
	
}