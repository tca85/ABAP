package br.com.ache.ntb2b_procnfe_ob.main;

import br.com.ache.ntb2b_procnfe_ob.model.NFeJavaMapping;
import br.com.ache.ntb2b_procnfe_ob.model.NFeJavaMappingException;

import com.sap.aii.mapping.api.StreamTransformationException;
import com.sap.aii.mapping.api.TransformationInput;
import com.sap.aii.mapping.api.TransformationOutput;

/**
 * 
 * @author Thiago Cordeiro Alves
 *
 */
public class Producao extends NFeJavaMapping{

	@Override
	public void transform(TransformationInput transformationInput, TransformationOutput transformationOutput) throws StreamTransformationException {
		// TODO Auto-generated method stub
	}

	@Override
	public void setEmpresaEmissora() throws NFeJavaMappingException {
		// TODO Auto-generated method stub	
	}
}