package br.com.ache.ntb2b_procnfe_ob.model;

import java.io.UnsupportedEncodingException;

import Decoder.BASE64Encoder;

/**
 * Classe Email 
 * 
 * @author Thiago Cordeiro Alves
 *
 */
public class Email {

	// ----------------------------------------------------------------------------------------------------------------
	// Atributos
	private String e_mailTo  ;
	private String e_mailFrom;
	private String empresa   ;
	private String assunto   ;

	// ----------------------------------------------------------------------------------------------------------------
	// Constantes
	private final static String CRLF = System.getProperty("line.separator");
	private final static String GAP = "\n\r";
	
	private static final String EMPRESA_ACHE              = "ACHE"               ;
	private static final String EMPRESA_BIOSINTETICA      = "BIOSINTETICA"       ;
	private static final String EMPRESA_LABOFARMA         = "LABOFARMA"          ;
	private static final String EMPRESA_MAFRA             = "MAFRA"              ;
	private static final String EMPRESA_PROPECUS          = "PROPECUS"           ;
	private static final String RAIZ_CNPJ_ACHE            = "60659463"           ;
	private static final String RAIZ_BIOSINTETICA         = "53162095"           ;
	private static final String RAIZ_LABOFARMA            = "07863523"           ;
	private static final String RAIZ_MAFRA                = "04972463"           ;
	private static final String RAIZ_PROPECUS             = "01299251"           ;
	private static final String EMAIL_ACHE_HOMOLOCAGAO    = "nfeh@ache.com.br"   ;
	private static final String EMAIL_ACHE_PRODUCAO       = "nfe@ache.com.br"    ;
	private static final String EMAIL_MAGENTA_HOMOLOCAGAO = "nfeh@magenta.com.br"; 
	private static final String EMAIL_MAGENTA_PRODUCAO    = "nfe@magenta.com.br" ;

	// ----------------------------------------------------------------------------------------------------------------
	// Enumerate
	public enum Emissor {
		ACHE_HOMOLOGACAO        (EMPRESA_ACHE        , RAIZ_CNPJ_ACHE   , EMAIL_ACHE_HOMOLOCAGAO   ),
		BIOSINTETICA_HOMOLOGACAO(EMPRESA_BIOSINTETICA, RAIZ_BIOSINTETICA, EMAIL_ACHE_HOMOLOCAGAO   ),
		LABOFARMA_HOMOLOGACAO   (EMPRESA_LABOFARMA   , RAIZ_LABOFARMA   , EMAIL_ACHE_HOMOLOCAGAO   ),
		MAFRA_HOMOLOGACAO       (EMPRESA_MAFRA       , RAIZ_MAFRA       , EMAIL_MAGENTA_HOMOLOCAGAO),
		PROPECUS_HOMOLOGACAO    (EMPRESA_PROPECUS    , RAIZ_PROPECUS    , EMAIL_MAGENTA_HOMOLOCAGAO),		
		ACHE_PRODUCAO           (EMPRESA_ACHE        , RAIZ_CNPJ_ACHE   , EMAIL_ACHE_PRODUCAO      ),
		BIOSINTETICA_PRODUCAO   (EMPRESA_BIOSINTETICA, RAIZ_BIOSINTETICA, EMAIL_ACHE_PRODUCAO      ),
		LABOFARMA_PRODUCAO      (EMPRESA_LABOFARMA   , RAIZ_LABOFARMA   , EMAIL_ACHE_PRODUCAO      ),
		MAFRA_PRODUCAO          (EMPRESA_MAFRA       , RAIZ_MAFRA       , EMAIL_MAGENTA_PRODUCAO   ),
		PROPECUS_PRODUCAO       (EMPRESA_PROPECUS    , RAIZ_PROPECUS    , EMAIL_MAGENTA_PRODUCAO   );
		
		private String empresa ;
		private String raizCNPJ;
		private String email   ;    	

		Emissor(String empresa, String raizCNPJ, String email){
			this.empresa  = empresa ;
			this.raizCNPJ = raizCNPJ;
			this.email    = email   ;    		
		}

		public String getEmpresa() {
			return empresa;
		}

		public String getraizCNPJ() {
			return raizCNPJ;
		}	

		public String getEmail() {
			return email;
		}    
	}
	
	// ----------------------------------------------------------------------------------------------------------------
	/**
	 * Construtor Padrão
	 */
	public Email(){	
	}
	
	// ----------------------------------------------------------------------------------------------------------------
	/**
	 * Construtor com parâmetros
	 * @param e_mailTo
	 * @param e_mailFrom
	 * @param empresa
	 * @param assunto
	 */
	public Email(String e_mailTo, String e_mailFrom, String empresa, String assunto){
		this.e_mailTo   = e_mailTo  ;
		this.e_mailFrom = e_mailFrom;
		this.empresa    = empresa   ;
		this.assunto    = assunto   ;
	}

	// ----------------------------------------------------------------------------------------------------------------
	// Métodos Getters e Setters
	public String getEmpresa() {
		return empresa;
	}

	public void setEmpresa(String empresa) {
		this.empresa = empresa;
	}

	public String getE_mailTo() {
		return e_mailTo;
	}

	public void setE_mailTo(String e_mailTo) {
		this.e_mailTo = e_mailTo.trim();
	}

	public String getE_mailFrom() {
		return e_mailFrom;
	}

	public void setE_mailFrom(String e_mailFrom) {
		this.e_mailFrom = e_mailFrom;
	}

	public String getAssunto() {
		return assunto;
	}

	public void setAssunto(String assunto) {
		this.assunto = assunto;
	}

	// ----------------------------------------------------------------------------------------------------------------
	
	/**
	 * Sobre-escrita do método toString
	 */
	@Override
	public String toString() {	
		return "E-mail de:   " + this.e_mailFrom + 
			   "E-mail para: " + this.e_mailTo   + 
			   "Empresa:     " + this.empresa    +
			   "Assunto:     " + this.assunto    ;		
	}
	
	// ----------------------------------------------------------------------------------------------------------------

	/**
	 * Gera o e-mail da NF-e com o arquivo em anexo
	 * 
	 * @param xmlNFe
	 * @return
	 */
	public String gerar_Email_NFe(String xmlNFe) {
		String email = "";

		try {
			BASE64Encoder base64 = new BASE64Encoder();

			String anexo_xml_NFe_Byte64 = base64.encode(xmlNFe.getBytes("UTF8"));

			String chaveAcesso = xmlNFe.substring(xmlNFe.indexOf("<chNFe>") + 7, xmlNFe.indexOf("<chNFe>") + 51);
			String numeroNFe   = chaveAcesso.substring(25, 34)                                                  ;
			String dataNFe     = chaveAcesso.substring(4, 6) + "/20" + chaveAcesso.substring(2, 4)              ;
			String serieNFe    = chaveAcesso.substring(22, 25)                                                  ;
			String nomeArquivo = "NFe" + "_" + empresa + "_" + chaveAcesso + ".xml"                             ;			

			email = "--" + "--AaZz"
					+ CRLF
					+ "Content-Type: text/plain; charset=UTF-8"
					+ CRLF
					+ "Content-Disposition: inline"
					+ CRLF
					+ "Prezado cliente, "
					+ GAP
					+ GAP
					+ "Segue arquivo XML anexo referente a Nota Fiscal Eletronica "
					+ GAP
					+ GAP
					+ "Numero da NF-e Autorizada: "
					+ numeroNFe
					+ GAP
					+ "Serie: "
					+ serieNFe
					+ GAP
					+ "Data emissao (MM/AAAA): "
					+ dataNFe
					+ GAP
					+ GAP
					+ CRLF
					+ CRLF
					+ "Para efetuar a consulta da sua NF-e favor acessar o link abaixo:"
					+ CRLF
					+ "http://www.nfe.fazenda.gov.br/PORTAL/Default.aspx"
					+ CRLF
					+ CRLF
					+ "Se voce usa um filtro de email ou um bloqueador de SPAM, o Ache"
					+ CRLF
					+ "recomenda que voce adicione o dominio \"ache.com.br\" a sua lista"
					+ CRLF + "de remetentes seguros." + CRLF + CRLF
					+ "Envio de e-mail automatico." + CRLF + CRLF
					+ "Favor nÃ£o responder." + CRLF + CRLF + "Atenciosamente,"
					+ CRLF + getEmpresa() + CRLF + "--" + "--AaZz" + CRLF
					+ "Content-Type: Application/xml; name=" + nomeArquivo
					+ CRLF + "Content-Transfer-Encoding: base64" + CRLF
					+ "Content-Disposition: xmlBase64; filename=" + nomeArquivo
					+ CRLF + CRLF + anexo_xml_NFe_Byte64;

		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}
		return email;
	}

	// ----------------------------------------------------------------------------------------------------------------
	/**
	 * Gera o e-mail da CC-e com o arquivo em anexo
	 * 
	 * @param xmlNFe
	 * @return
	 */
	public String gerar_Email_CCe(String xmlNFe) {
		String email = "";

		try {
			BASE64Encoder base64 = new BASE64Encoder();

			String anexo_xml_NFe_Byte64 = base64.encode(xmlNFe.getBytes("UTF8"));
			
			String chaveAcesso = xmlNFe.substring(xmlNFe.indexOf("<chNFe>") + 7, xmlNFe.indexOf("<chNFe>") + 51);
			String numeroNFe   = chaveAcesso.substring(25, 34)                                                  ;
			String dataNFe     = chaveAcesso.substring(4, 6) + "/20" + chaveAcesso.substring(2, 4)              ;
			String serieNFe    = chaveAcesso.substring(22, 25)                                                  ;
			String nomeArquivo = "CC-e" + "_" + empresa + "_" + chaveAcesso	+ ".xml"                            ;
			
			email = "--" + "--AaZz"
					+ CRLF
					+ "Content-Type: text/plain; charset=UTF-8"
					+ CRLF
					+ "Content-Disposition: inline"
					+ CRLF
					+ "Prezado cliente, "
					+ GAP
					+ GAP
					+ "Segue arquivo XML anexo referente ao evento da Nota Fiscal Eletronica."
					+ GAP + GAP + "Numero da NF-e que recebeu o evento: "
					+ numeroNFe + GAP + "Serie: " + serieNFe + GAP
					+ "Data emissao (MM/AAAA): " + dataNFe + GAP + GAP
					+ "Atenciosamente," + GAP + GAP + empresa + CRLF + "--"
					+ "--AaZz" + CRLF + "Content-Type: Application/xml; name="
					+ nomeArquivo + CRLF + "Content-Transfer-Encoding: base64"
					+ CRLF + "Content-Disposition: xmlBase64; filename="
					+ nomeArquivo + CRLF + CRLF + anexo_xml_NFe_Byte64;

		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}

		return email;
	}

	// ----------------------------------------------------------------------------------------------------------------
	
	/**
	 * 
	 * @param xmlNFe
	 * @return
	 */
	public String getTextoCancelamentoNFe(String xmlNFe) {
		String email = "";

		try {
			BASE64Encoder base64 = new BASE64Encoder();

			String anexo_xml_NFe_Byte64 = base64.encode(xmlNFe.getBytes("UTF8"))                                ;

			String chaveAcesso = xmlNFe.substring(xmlNFe.indexOf("<chNFe>") + 7, xmlNFe.indexOf("<chNFe>") + 51);
			String numeroNFe   = chaveAcesso.substring(25, 34)                                                  ;
			String dataNFe     = chaveAcesso.substring(4, 6) + "/20" + chaveAcesso.substring(2, 4)              ;
			String serieNFe    = chaveAcesso.substring(22, 25)                                                  ;
			String nomeArquivo = "NFe" + "_" + empresa + "_" + chaveAcesso + ".xml"                             ;

			email = "----AaZz\r\n Content-Type: text/plain; charset=UTF-8\r\n"
					+ "Content-Disposition: inline\r\n\r\n"
					+ "Prezado cliente, "
					+ GAP
					+ GAP
					+ "Segue arquivo XML anexo referente ao Cancelamento da Nota Fiscal Eletronica."
					+ GAP
					+ GAP
					+ "Numero da NF-e cancelada: "
					+ numeroNFe
					+ GAP
					+ "Serie: "
					+ serieNFe
					+ GAP
					+ "Data emissao (MM/AAAA): "
					+ dataNFe
					+ GAP
					+ GAP
					+ "Atenciosamente,"
					+ GAP
					+ GAP
					+ empresa
					+ "\r\n----AaZz\r\nContent-Type: text/xml; charset=UTF-8\r\nContent-Disposition: attachment; filename="
					+ nomeArquivo + "\r\n\r\n" + anexo_xml_NFe_Byte64 + "\r\n";

		} catch (UnsupportedEncodingException e) {
			e.printStackTrace();
		}

		return email;
	}
	// ----------------------------------------------------------------------------------------------------------------
}