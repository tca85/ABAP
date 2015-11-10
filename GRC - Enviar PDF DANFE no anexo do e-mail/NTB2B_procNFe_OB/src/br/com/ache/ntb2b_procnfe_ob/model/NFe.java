package br.com.ache.ntb2b_procnfe_ob.model;

/**
 * Classe NFe
 * @author Thiago Cordeiro Alves
 *
 */
public class NFe {

	// ----------------------------------------------------------------------------------------------------------------
	// Atributos
	private String xml          ;
	private String id           ;
	private String serie        ;
	private String CNPJ_Emitente;
	private String raizCNPJ     ;

	// ----------------------------------------------------------------------------------------------------------------
	/**
	 * Construtor Padrão
	 */
	public NFe(){
	}

	// ----------------------------------------------------------------------------------------------------------------
	// Getters e Setters
	public String getXml() {
		return xml;
	}

	public void setXml(String xml) {
		this.xml = xml;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getSerie() {
		return serie;
	}

	public void setSerie(String serie) {
		this.serie = serie;
	}

	public String getCNPJ_Emitente() {
		return CNPJ_Emitente;
	}

	public void setCNPJ_Emitente(String cNPJ_Emitente) {
		CNPJ_Emitente = cNPJ_Emitente;
	}

	public String getRaizCNPJ() {
		return raizCNPJ;
	}

	public void setRaizCNPJ(String raizCNPJ) {
		this.raizCNPJ = raizCNPJ;
	}
	// ----------------------------------------------------------------------------------------------------------------
}