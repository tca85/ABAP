package br.com.ache.ntb2b_procnfe_ob.main;

import java.io.InputStream;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.TransformerException;

import br.com.ache.ntb2b_procnfe_ob.model.Email;
import br.com.ache.ntb2b_procnfe_ob.model.NFeJavaMapping;
import br.com.ache.ntb2b_procnfe_ob.model.NFeJavaMappingException;

import com.sap.aii.mapping.api.StreamTransformationException;
import com.sap.aii.mapping.api.TransformationInput;
import com.sap.aii.mapping.api.TransformationOutput;


/**
 * Classe Homologacao herda da classe abstrata NFeJavaMapping.
 * Dentro dela tem o método transform, que o PI usa
 * 
 * @author Thiago Cordeiro Alves
 *
 */
public class Homologacao extends NFeJavaMapping{
	
	// ----------------------------------------------------------------------------------------------------------------
	/**
	 * O JavaMapping do PI chama esse método. É obrigatório herdar a classe AbstractTransformation
	 * e reescrever o método transform
	 */
	@Override
	public void transform(TransformationInput transformationInput, TransformationOutput transformationOutput) throws StreamTransformationException {
		
		try {
			InputStream inputStream = transformationInput.getInputPayload().getInputStream();
			
			// Busca o destinatário do e-mail que vem no anexo, e remove ele do anexo
			super.setDestinatarioEmail(transformationInput, transformationOutput);		

			super.setDetalhesNFe(inputStream);

			this.setEmpresaEmissora();

			super.setXMLSaida(transformationOutput);

		} catch (NFeJavaMappingException e) {
			getTrace().addInfo(e.getMessage());				    
		} catch (ParserConfigurationException e){
		   getTrace().addInfo(e.getMessage());
		} catch (TransformerException e){
			getTrace().addInfo(e.getMessage());
		}		
	}	
	
	// ----------------------------------------------------------------------------------------------------------------
	/**
	 * Obtém detalhes da empresa que emite a NF-e
	 */
	@Override
	public void setEmpresaEmissora() throws NFeJavaMappingException{
		String assuntoEmail = "NFE #empresa# : #id# - #serie#";

		assuntoEmail = assuntoEmail.replaceFirst("#id#", nfe.getId());
		assuntoEmail = assuntoEmail.replaceFirst("#serie#", nfe.getSerie());
				
		   // 60659463 - Raiz CNPJ doAché
		if (nfe.getRaizCNPJ().equals(Email.Emissor.ACHE_HOMOLOGACAO.getraizCNPJ())) {
			email.setE_mailFrom(Email.Emissor.ACHE_HOMOLOGACAO.getEmail());
			email.setEmpresa(Email.Emissor.ACHE_HOMOLOGACAO.getEmpresa());
			email.setAssunto(assuntoEmail.replaceFirst("#empresa#", Email.Emissor.ACHE_HOMOLOGACAO.getEmpresa()));

			// 04972463 - Raiz CNPJ da Mafra
		} else if (nfe.getRaizCNPJ().equals(Email.Emissor.MAFRA_HOMOLOGACAO.getraizCNPJ())) {
			email.setE_mailFrom(Email.Emissor.MAFRA_HOMOLOGACAO.getEmail());
			email.setEmpresa(Email.Emissor.MAFRA_HOMOLOGACAO.getEmpresa());
			email.setAssunto(assuntoEmail.replaceFirst("#empresa#", Email.Emissor.MAFRA_HOMOLOGACAO.getEmpresa()));

			// 01299251 - Raiz CNPJ da Propecus
		} else if (nfe.getRaizCNPJ().equals(Email.Emissor.PROPECUS_HOMOLOGACAO.getraizCNPJ())) {
			email.setE_mailFrom(Email.Emissor.PROPECUS_HOMOLOGACAO.getEmail());
			email.setEmpresa(Email.Emissor.PROPECUS_HOMOLOGACAO.getEmpresa());
			email.setAssunto(assuntoEmail.replaceFirst("#empresa#",	Email.Emissor.PROPECUS_HOMOLOGACAO.getEmpresa()));

			// 53162095 - Raiz CNPJ da Biosintética
		} else if (nfe.getRaizCNPJ().equals(Email.Emissor.BIOSINTETICA_HOMOLOGACAO.getraizCNPJ())) {
			email.setE_mailFrom(Email.Emissor.BIOSINTETICA_HOMOLOGACAO.getEmail());
			email.setEmpresa(Email.Emissor.BIOSINTETICA_HOMOLOGACAO.getEmpresa());
			email.setAssunto(assuntoEmail.replaceFirst("#empresa#", Email.Emissor.BIOSINTETICA_HOMOLOGACAO.getEmpresa()));

		} else if (nfe.getRaizCNPJ().equals(Email.Emissor.LABOFARMA_HOMOLOGACAO.getraizCNPJ())) {
			email.setE_mailFrom(Email.Emissor.LABOFARMA_HOMOLOGACAO.getEmail());
			email.setEmpresa(Email.Emissor.LABOFARMA_HOMOLOGACAO.getEmpresa());
			email.setAssunto(assuntoEmail.replaceFirst("#empresa#",	Email.Emissor.LABOFARMA_HOMOLOGACAO.getEmpresa()));
			
		} else {
			throw new NFeJavaMappingException("Dados da empressa emissora não foram encontrados");
		}
	}
	// ----------------------------------------------------------------------------------------------------------------
}
