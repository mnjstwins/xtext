/**
 * Copyright (c) 2012 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 */
package org.eclipse.xtend.macro.lang.processing;

import com.google.common.collect.Iterables;
import com.google.inject.Inject;
import java.util.List;
import java.util.Set;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.EReference;
import org.eclipse.emf.ecore.InternalEObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtend.core.xtend.XtendAnnotationTarget;
import org.eclipse.xtend.core.xtend.XtendAnnotationType;
import org.eclipse.xtend.core.xtend.XtendClass;
import org.eclipse.xtend.core.xtend.XtendConstructor;
import org.eclipse.xtend.core.xtend.XtendField;
import org.eclipse.xtend.core.xtend.XtendFunction;
import org.eclipse.xtend.core.xtend.XtendParameter;
import org.eclipse.xtend.macro.lang.macro.MacroAnnotation;
import org.eclipse.xtext.common.types.JvmAnnotationType;
import org.eclipse.xtext.linking.ILinkingService;
import org.eclipse.xtext.linking.lazy.LazyURIEncoder;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.util.Triple;
import org.eclipse.xtext.xbase.annotations.xAnnotations.XAnnotation;
import org.eclipse.xtext.xbase.annotations.xAnnotations.XAnnotationsPackage.Literals;
import org.eclipse.xtext.xbase.jvmmodel.IJvmModelAssociations;
import org.eclipse.xtext.xbase.lib.Functions.Function1;
import org.eclipse.xtext.xbase.lib.IterableExtensions;

@SuppressWarnings("all")
public class XAnnotationExtensions {
  @Inject
  private IJvmModelAssociations associations;
  
  @Inject
  private LazyURIEncoder encoder;
  
  @Inject
  private ILinkingService linkingService;
  
  public XtendAnnotationTarget getAnnotatedTarget(final XAnnotation annotation) {
    XtendAnnotationTarget _switchResult = null;
    EObject _eContainer = annotation.eContainer();
    final EObject container = _eContainer;
    boolean _matched = false;
    if (!_matched) {
      if (container instanceof XtendAnnotationType) {
        final XtendAnnotationType _xtendAnnotationType = (XtendAnnotationType)container;
        _matched=true;
        _switchResult = _xtendAnnotationType;
      }
    }
    if (!_matched) {
      if (container instanceof XtendClass) {
        final XtendClass _xtendClass = (XtendClass)container;
        _matched=true;
        _switchResult = _xtendClass;
      }
    }
    if (!_matched) {
      if (container instanceof XtendField) {
        final XtendField _xtendField = (XtendField)container;
        _matched=true;
        _switchResult = _xtendField;
      }
    }
    if (!_matched) {
      if (container instanceof XtendFunction) {
        final XtendFunction _xtendFunction = (XtendFunction)container;
        _matched=true;
        _switchResult = _xtendFunction;
      }
    }
    if (!_matched) {
      if (container instanceof XtendConstructor) {
        final XtendConstructor _xtendConstructor = (XtendConstructor)container;
        _matched=true;
        _switchResult = _xtendConstructor;
      }
    }
    if (!_matched) {
      if (container instanceof XtendParameter) {
        final XtendParameter _xtendParameter = (XtendParameter)container;
        _matched=true;
        _switchResult = _xtendParameter;
      }
    }
    if (!_matched) {
      if (container instanceof XtendAnnotationTarget) {
        final XtendAnnotationTarget _xtendAnnotationTarget = (XtendAnnotationTarget)container;
        _matched=true;
        EObject _eContainer_1 = _xtendAnnotationTarget.eContainer();
        _switchResult = ((XtendAnnotationTarget) _eContainer_1);
      }
    }
    if (!_matched) {
      if (container instanceof XAnnotation) {
        final XAnnotation _xAnnotation = (XAnnotation)container;
        _matched=true;
        XtendAnnotationTarget _annotatedTarget = this.getAnnotatedTarget(_xAnnotation);
        _switchResult = _annotatedTarget;
      }
    }
    if (!_matched) {
      _switchResult = null;
    }
    return _switchResult;
  }
  
  /**
   * Checks whether this annotation is pointing to a processed annotation, without resolving the proxy
   */
  public boolean isProcessed(final XAnnotation it) {
    Object _eGet = it.eGet(Literals.XANNOTATION__ANNOTATION_TYPE);
    final Object proxy = _eGet;
    boolean _matched = false;
    if (!_matched) {
      if (proxy instanceof EObject) {
        final EObject _eObject = (EObject)proxy;
        boolean _eIsProxy = _eObject.eIsProxy();
        if (_eIsProxy) {
          _matched=true;
          final URI uri = ((InternalEObject) _eObject).eProxyURI();
          Resource _eResource = it.eResource();
          String _fragment = uri.fragment();
          boolean _isCrossLinkFragment = this.encoder.isCrossLinkFragment(_eResource, _fragment);
          if (_isCrossLinkFragment) {
            Resource _eResource_1 = it.eResource();
            String _fragment_1 = uri.fragment();
            final Triple<EObject,EReference,INode> triple = this.encoder.decode(_eResource_1, _fragment_1);
            EObject _first = triple.getFirst();
            EReference _second = triple.getSecond();
            INode _third = triple.getThird();
            final List<EObject> candidates = this.linkingService.getLinkedObjects(_first, _second, _third);
            boolean _isEmpty = candidates.isEmpty();
            boolean _not = (!_isEmpty);
            if (_not) {
              EObject _head = IterableExtensions.<EObject>head(candidates);
              return this.isProcessedAnnotation(((JvmAnnotationType) _head));
            }
          }
        }
      }
    }
    if (!_matched) {
      if (proxy instanceof JvmAnnotationType) {
        final JvmAnnotationType _jvmAnnotationType = (JvmAnnotationType)proxy;
        _matched=true;
        return this.isProcessedAnnotation(_jvmAnnotationType);
      }
    }
    return false;
  }
  
  public MacroAnnotation getMacroAnnotation(final JvmAnnotationType it) {
    Set<EObject> _sourceElements = this.associations.getSourceElements(it);
    Iterable<MacroAnnotation> _filter = Iterables.<MacroAnnotation>filter(_sourceElements, MacroAnnotation.class);
    MacroAnnotation _head = IterableExtensions.<MacroAnnotation>head(_filter);
    return _head;
  }
  
  public MacroAnnotation getMacroAnnotation(final XAnnotation it) {
    Object _eGet = it.eGet(Literals.XANNOTATION__ANNOTATION_TYPE);
    final Object proxy = _eGet;
    boolean _matched = false;
    if (!_matched) {
      if (proxy instanceof EObject) {
        final EObject _eObject = (EObject)proxy;
        boolean _eIsProxy = _eObject.eIsProxy();
        if (_eIsProxy) {
          _matched=true;
          final URI uri = ((InternalEObject) _eObject).eProxyURI();
          Resource _eResource = it.eResource();
          String _fragment = uri.fragment();
          boolean _isCrossLinkFragment = this.encoder.isCrossLinkFragment(_eResource, _fragment);
          if (_isCrossLinkFragment) {
            Resource _eResource_1 = it.eResource();
            String _fragment_1 = uri.fragment();
            final Triple<EObject,EReference,INode> triple = this.encoder.decode(_eResource_1, _fragment_1);
            EObject _first = triple.getFirst();
            EReference _second = triple.getSecond();
            INode _third = triple.getThird();
            final List<EObject> candidates = this.linkingService.getLinkedObjects(_first, _second, _third);
            boolean _isEmpty = candidates.isEmpty();
            boolean _not = (!_isEmpty);
            if (_not) {
              EObject _head = IterableExtensions.<EObject>head(candidates);
              return this.getMacroAnnotation(((JvmAnnotationType) _head));
            }
          }
        }
      }
    }
    if (!_matched) {
      if (proxy instanceof JvmAnnotationType) {
        final JvmAnnotationType _jvmAnnotationType = (JvmAnnotationType)proxy;
        _matched=true;
        return this.getMacroAnnotation(_jvmAnnotationType);
      }
    }
    return null;
  }
  
  protected boolean isProcessedAnnotation(final JvmAnnotationType annotationType) {
    Set<EObject> _sourceElements = this.associations.getSourceElements(annotationType);
    final Function1<EObject,Boolean> _function = new Function1<EObject,Boolean>() {
        public Boolean apply(final EObject e) {
          return Boolean.valueOf((e instanceof MacroAnnotation));
        }
      };
    boolean _exists = IterableExtensions.<EObject>exists(_sourceElements, _function);
    return _exists;
  }
}