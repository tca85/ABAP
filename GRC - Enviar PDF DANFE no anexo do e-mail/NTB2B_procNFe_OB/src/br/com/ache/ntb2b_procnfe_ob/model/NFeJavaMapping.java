/**
 * ----------------------------------------------------------------------------------------------------------------
 * Todo JavaMapping precisa herdar da classe AbstractTransformation:
 * http://help.sap.com/javadocs/pi/sp3/xpi/com/sap/aii/mapping/api/AbstractTransformation.html
 * obs.: classes abstratas não podem ser instanciadas, só podem ser herdadas
 * ----------------------------------------------------------------------------------------------------------------
 * Local para importar o arquivo no SAP PI após exportar em formato .JAR
 * ----------------------------------------------------------------------------------------------------------------
 * Enterprise Services Builder (Repository)
 * Software Component Version: ZNFE_B2B of fh
 * Namespace.................: urn://br.com.ache/Nfe/B2B
 * Imported Archive..........: arquivo.jar
 * Namespace.................: http://sap.com/xi/NFE/008
 * Operation Mapping.........: NTB2B_procNFe_TO_procNFe
 * ----------------------------------------------------------------------------------------------------------------
 * Modificações
 * ----------------------------------------------------------------------------------------------------------------
 * Java 1.6.0_27
 * Data de modificação.......: 07.08.2015
 * 
 * @author Thiago Cordeiro Alves
 *----------------------------------------------------------------------------------------------------------------
 */
package br.com.ache.ntb2b_procnfe_ob.model;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.Reader;
import java.util.Collection;
import java.util.Iterator;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Text;

import com.sap.aii.mapping.api.AbstractTransformation;
import com.sap.aii.mapping.api.Attachment;
import com.sap.aii.mapping.api.InputAttachments;
import com.sap.aii.mapping.api.OutputAttachments;
import com.sap.aii.mapping.api.StreamTransformationException;
import com.sap.aii.mapping.api.TransformationInput;
import com.sap.aii.mapping.api.TransformationOutput;

public abstract class NFeJavaMapping extends AbstractTransformation {

	// ----------------------------------------------------------------------------------------------------------------
	// Atributos
	protected Email email = new Email();
	protected NFe   nfe   = new NFe()  ;

	// ----------------------------------------------------------------------------------------------------------------
	/**
	 * O JavaMapping do PI chama esse método
	 * obs: quem herdar essa classe, será obrigado a reescrever ele
	 */
	
	@Override
	public abstract void transform(TransformationInput transformationInput, TransformationOutput transformationOutput) throws StreamTransformationException;	

	// ----------------------------------------------------------------------------------------------------------------
	/**
	 * Verificar qual empresa está enviando o XML para o cliente
	 * obs: quem herdar essa classe, será obrigado a reescrever ele
	 * @throws NFeJavaMappingException
	 */
	public abstract void setEmpresaEmissora() throws NFeJavaMappingException;
		
	// ----------------------------------------------------------------------------------------------------------------
	/**
	 * Obtém o destinatário do e-mail que vem dentro de um anexo
	 * 
	 * @param transformationInput
	 * @param transformationOutput
	 * @throws Exception
	 */
	public void setDestinatarioEmail(TransformationInput transformationInput, TransformationOutput transformationOutput) throws NFeJavaMappingException {

		InputAttachments inputAttachments = transformationInput.getInputAttachments();

		if (inputAttachments != null) {
			if (inputAttachments.areAttachmentsAvailable()) {

				Collection<?> colAttachments = inputAttachments.getAllContentIds(true);
				Iterator<?> itAttachments = colAttachments.iterator();

				String attachmentID   = "";
				String emailTo        = "";
				Attachment attachment = null;

				while (itAttachments.hasNext()) {
					attachmentID = (String) itAttachments.next();
					attachment   = inputAttachments.getAttachment(attachmentID);

					emailTo = converterByte2String(attachment.getContent());

					if (emailTo.isEmpty()) {
						throw new NFeJavaMappingException("Destinatario do e-mail não encontrado");
					} else {
						email.setE_mailTo(emailTo);
					}

					OutputAttachments outputAttachments = transformationOutput.getOutputAttachments();

					transformationOutput.getOutputAttachments().removeAttachment(attachmentID);
					outputAttachments.removeAttachment(attachmentID);
				}

				itAttachments = null;
				colAttachments = null;
			}
		} else {
			throw new NFeJavaMappingException("Anexo com o destinatário do e-mail não foi recebido");
		}
	}

	// ----------------------------------------------------------------------------------------------------------------
	/**
	 * Detalhes da NF-e
	 * 
	 * @param inputStream
	 */
	public void setDetalhesNFe(InputStream inputStream) throws NFeJavaMappingException{
		String xmlNFe = converterInputStream2String(inputStream);
		
		xmlNFe = xmlNFe.replaceAll("n0:", "").replaceAll(" xmlns:n0=\"http://www.portalfiscal.inf.br/nfe\"","").replaceAll("utf-8", "UTF-8");

		String idNFe    = xmlNFe.substring(xmlNFe.indexOf("<chNFe>") + 7, xmlNFe.indexOf("<chNFe>") + 51);
		String serieNFe = idNFe.substring(22, 25);
		String cnpjEmit = idNFe.substring(6, 20);
		String raizCNPJ = cnpjEmit.substring(0, 8);

		nfe.setXml(xmlNFe)            ;
		nfe.setId(idNFe)              ;
		nfe.setSerie(serieNFe)        ;
		nfe.setCNPJ_Emitente(cnpjEmit);
		nfe.setRaizCNPJ(raizCNPJ)     ;
		
		if (xmlNFe.isEmpty()) {
			throw new NFeJavaMappingException("XML não foi encontrado");
		}		
	}
	
	// ----------------------------------------------------------------------------------------------------------------

	/**
	 * Configura o XML de saída
	 * @param transformationOutput
	 * @throws ParserConfigurationException
	 * @throws TransformerException
	 */
	public void setXMLSaida(TransformationOutput transformationOutput) throws ParserConfigurationException, TransformerException {

		OutputStream outputStream = transformationOutput.getOutputPayload().getOutputStream();
	    DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		DocumentBuilder db = dbf.newDocumentBuilder();

		// Cria escopo do XML
		Document document = db.newDocument();
		Element root = document.createElement("ns1:Mail");

		root.setAttribute("xmlns:ns1", "http://sap.com/xi/XI/Mail/30");
		document.appendChild(root);

		// Cria elemento From
		Element from = document.createElement("From");
		root.appendChild(from);
		Text fromText = document.createTextNode(email.getE_mailFrom());
		from.appendChild(fromText);

		// Cria elemento To
		Element to = document.createElement("To");
		root.appendChild(to);
		Text toText = document.createTextNode(email.getE_mailTo());
		to.appendChild(toText);

	    // Cria elemento Subject
		Element subject = document.createElement("Subject");
		root.appendChild(subject);
		Text subjectText = document.createTextNode(email.getAssunto());
		subject.appendChild(subjectText);

		// Cria elemento Content Type
		Element contentType = document.createElement("Content_Type");
		root.appendChild(contentType);
		Text contentTypeText = document.createTextNode("multipart/mixed;boundary=--AaZz");
		contentType.appendChild(contentTypeText);

		Text contentText = null;

		if (nfe.getXml().indexOf("infEvento") > 0) {
			contentText = document.createTextNode(email.gerar_Email_CCe(nfe.getXml()));
		} else {
			contentText = document.createTextNode(email.gerar_Email_NFe(nfe.getXml()));
		}

		// Cria elemento Content
		Element content = document.createElement("Content");
		root.appendChild(content);
		content.appendChild(contentText);

		TransformerFactory tf = TransformerFactory.newInstance();
		Transformer transform = tf.newTransformer();

		// Fecha o XML
		DOMSource domS = new DOMSource(document);
		transform.transform((domS), new StreamResult(outputStream));
	}

	// ----------------------------------------------------------------------------------------------------------------
	/**
	 * Converte InputStream para String
	 * 
	 * @param _in
	 * @return
	 */
	private String converterInputStream2String(InputStream inputStream) {
		StringBuffer sb = new StringBuffer();

		try {
			InputStreamReader isr = new InputStreamReader(inputStream);
			Reader reader = new BufferedReader(isr);
			int ch;

			while ((ch = inputStream.read()) > -1) {
				sb.append((char) ch);
			}
			reader.close();
		} catch (Exception exception) {

		}
		return sb.toString();
	}

	// ----------------------------------------------------------------------------------------------------------------
	/**
	 * Converter Byte para String
	 * 
	 * @param _bytes
	 * @return
	 */
	private String converterByte2String(byte[] bytes) {
		String file_string = "";

		for (int i = 0; i < bytes.length; i++) {
			file_string += (char) bytes[i];
		}
		return file_string;
	}
	// ----------------------------------------------------------------------------------------------------------------
}