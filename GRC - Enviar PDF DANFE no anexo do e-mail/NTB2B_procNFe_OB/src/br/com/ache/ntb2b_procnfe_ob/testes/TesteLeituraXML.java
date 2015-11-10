package br.com.ache.ntb2b_procnfe_ob.testes;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Collection;
import java.util.Iterator;

import com.sap.aii.mapping.api.AbstractTransformation;
import com.sap.aii.mapping.api.Attachment;
import com.sap.aii.mapping.api.DynamicConfiguration;
import com.sap.aii.mapping.api.InputAttachments;
import com.sap.aii.mapping.api.OutputAttachments;
import com.sap.aii.mapping.api.StreamTransformationException;
import com.sap.aii.mapping.api.TransformationInput;
import com.sap.aii.mapping.api.TransformationOutput;

public class TesteLeituraXML extends AbstractTransformation {
	InputAttachments inputAttachments = null;
	OutputAttachments outputAttachments = null;
	DynamicConfiguration conf = null;

	public static void main(String[] args) throws Exception {
		InputStream in = new FileInputStream("C:/Temp/35150560750056000195550010004670791100000008-nfe.xml");
		OutputStream out = new FileOutputStream("C:/Temp/nfe_b2b_out.xml");

		new TesteLeituraXML().execute(in, out);
		in.close();
		out.flush();
		out.close();
	}

	@Override
	public void transform(TransformationInput tf_in, TransformationOutput tf_out) throws StreamTransformationException {
		inputAttachments = tf_in.getInputAttachments();
		outputAttachments = tf_out.getOutputAttachments();
		conf = tf_in.getDynamicConfiguration();
		
		this.execute(tf_in.getInputPayload().getInputStream(), tf_out.getOutputPayload().getOutputStream());
	}


	public void execute(InputStream in, OutputStream out) throws StreamTransformationException {
		Attachment attachment = null;		
		String aId = "";
		
		try {
			if (inputAttachments != null) {
				if (inputAttachments.areAttachmentsAvailable()) {
					
					Collection<String> attachments = inputAttachments.getAllContentIds(true);
					Iterator<String> it = attachments.iterator();
					
					while (it.hasNext()) {
						aId = it.next();		
						attachment = inputAttachments.getAttachment(aId);								
						outputAttachments.removeAttachment(aId);
					}
					
					out.write(attachment.getContent());			
				}
			}
			
		} catch (Exception e) {
			throw new StreamTransformationException(e.getMessage());
		}
	}
}