package org.eclipse.xtend.ide.refactoring;

import static java.util.Collections.*;

import java.util.List;

import org.eclipse.core.resources.IFile;
import org.eclipse.core.runtime.IPath;
import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.xtend.core.xtend.XtendClass;
import org.eclipse.xtext.EcoreUtil2;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.refactoring.IChangeRedirector;
import org.eclipse.xtext.ui.refactoring.IRenameRefactoringProvider;
import org.eclipse.xtext.ui.refactoring.impl.AbstractProcessorBasedRenameParticipant;
import org.eclipse.xtext.ui.refactoring.ui.IRenameContextFactory;
import org.eclipse.xtext.ui.refactoring.ui.IRenameElementContext;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;

import com.google.inject.Inject;

public class XtendFileRenameParticipant extends AbstractProcessorBasedRenameParticipant {

	@Inject
	private IRenameRefactoringProvider renameRefactoringProvider;

	@Inject
	private IResourceSetProvider resourceSetProvider;

	@Inject
	private IRenameContextFactory renameContextFactory;

	@Override
	protected List<? extends IRenameElementContext> createRenameElementContexts(Object element) {
		IFile file = (IFile) element;
		final IPath filePath = file.getFullPath();
		final IPath newPath = file.getFullPath().removeLastSegments(1).append(getNewName() + ".xtend");
		String className = trimFileExtension(file.getName());
		ResourceSet resourceSet = resourceSetProvider.get(file.getProject());
		URI resourceURI = URI.createPlatformResourceURI(file.getFullPath().toString(), true);
		Resource resource = resourceSet.getResource(resourceURI, true);
		if (resource != null && !resource.getContents().isEmpty()) {
			for (XtendClass clazz : EcoreUtil2.eAllOfType(resource.getContents().get(0), XtendClass.class)) {
				if (clazz.getName().equals(className)) {
					IRenameElementContext renameElementContext = renameContextFactory.createRenameElementContext(clazz, null, null,
							(XtextResource) resource);
					if(renameElementContext instanceof IChangeRedirector.Aware) 
						((IChangeRedirector.Aware) renameElementContext).setChangeRedirector(new IChangeRedirector() {
							public IPath getRedirectedPath(IPath source) {
								return source.equals(filePath) ? newPath : filePath;
							}
							
						});
					return singletonList(renameElementContext);
				}
			}
		}
		return super.createRenameElementContexts(element);
	}

	@Override
	protected String getNewName() {
		return trimFileExtension(super.getNewName());
	}
	
	protected String trimFileExtension(String fileName) {
		if (fileName.lastIndexOf('.') == -1)
			return fileName;
		return fileName.substring(0, fileName.lastIndexOf('.'));
	}
	
	@Override
	protected List<EObject> getRenamedElementsOrProxies(EObject originalTarget) {
		return singletonList(originalTarget);
	}
}