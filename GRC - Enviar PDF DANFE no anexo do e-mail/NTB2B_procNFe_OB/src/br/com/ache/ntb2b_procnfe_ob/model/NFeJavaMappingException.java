package br.com.ache.ntb2b_procnfe_ob.model;

public class NFeJavaMappingException extends Exception {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * 
	 */
	public NFeJavaMappingException(String mensagem) {
		super("Erro: " + mensagem);
	}

}
