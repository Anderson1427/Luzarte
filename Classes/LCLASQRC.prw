#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#Include "TBICONN.ch"
#Include "zLib.ch"

// ----------------------------------------------
/*/ Classe LCLASQRC

  Classe para geração do QR Code.

  @author Anderson Almeida (TOTVS NE)
  @historia
    11/07/2023 - Desenvolvimento da Rotina.
/*/
// -----------------------------------------------
Class LCLASQRC
  Data cQRData as String
  Data cErrC   as String
  Data cMask   as String
  Data nMode   as Int
  Data aMasks  as Array                
  Data aErrorC as Array
  Data oQR

  Method New() Constructor
  Method NewQRCode(oQR,cQRData,cErrC,nMode,cMask,oBMPQRCode)   // Geração do QR Code
//  Method Export(oQR)                                        // Exporta o QR Code para imagem BITMAP 
EndClass

//--------------------------------------
/*/ Classe LCLASQRC

  Definição do construtor da classe

  @author Anderson Almeida (TOTVS NE)
  @since 11/07/2023	
/*/
//--------------------------------------
Method New() Class LCLASQRC
  self:cQRData := ""
  self:cErrC   := ""
  self:nMode   := 2
  self:aErrorC := {"L.Low", "M.Medium", "Q.Quartile", "H.High"}
  self:oQR     := Nil
/*
  Local nX := 0                
  
  For nX := 0 To 7
	  aAdd(self:aMasks, cValToChar(nX) + ".Mask " + cValToChar(nX))
  Next

  oBmpQRCode:nWidth := 29*MODULE_PIXEL_SIZE  
  oBmpQRCode:nHeight := 29*MODULE_PIXEL_SIZE
  oBmpQRCode:lStretch := .T.

// Botao para a geracão do QR Code
@ 85,50 BUTTON oButton1 PROMPT "&Gerar QR Code" ;
  ACTION (NewQRCode(@oQR,cQRData,cErrC,nMode,cMask,oBMPQRCode)) ;
  SIZE 080, 013 of oDlg  PIXEL

@ 100,50 BUTTON oButton2 PROMPT "&Exportar Imagem" ;
  ACTION (ExportImg(oQR)) WHEN oQR != NIL ;
  SIZE 080, 013 of oDlg  PIXEL

ACTIVATE DIALOG oDlg CENTER 
*/
Return Self
 
//--------------------------------------
/*/ Classe LCLASQRC
  Método : NewQRCode
  
    Geração do QR Code na interface.

  @author Anderson Almeida (TOTVS NE)
  @since 11/07/2023	
/*/
//--------------------------------------
Method NewQRCode(oQR,cQRData,cErrC,nMode,cMask,oBMPQRCode) Class LCLASQRC
  Local nX   := 0
  Local nY   := 0
  Local oBMP := Nil

  If oQR != Nil
	FreeObj(oQR)
  EndIf

  oQR := ZQRCODE():New()    // Cria QRCode vazio 

 // -- Trata os dados informados
 // ---------------------------- 
  cQRData := AllTrim(cQRData)
  cErrC   := Left(cErrC,1)
  cMask   := Left(cMask,1)
                             
  If Empty(cQRData)
	 MsgStop("Dados para o QR Code não informados.")
  EndIf

 // -- Inicializa o QRCode com Error Correction "L", 
 // -- sem versao definida. Informa o Error Correction.
 // ---------------------------------------------------
  oQR:SetEC(cErrC)

 // -- Seta o dado a ser colocado no QRCode e seta o
 // -- modo de codificacao (1 = Numerico, 2 = Alfanumerico,
 // -- 3 = Bytes , 4 = Kanji)
 // -------------------------------------------------------
  oQR:SetData(cQRData,nMode)

 // -- Monta a matriz de dados. 
 // -- Se a versao nao foi especificada, determina de acordo 
 // -- com o tamanho dos dados a serem plotados.
 // -- oQR:oLogger:SETECHO(.T.)
 // --------------------------------------------------------
  oQR:BuildData()

  oQR:DeployBits()    // Monta a matriz final do QRCode 

 // -- Seleciona a mascara de dados.
 // -- Caso seja automatico, nao informa para a engine de 
 // -- emissão decidir. O método SelectMask já aplica a máscara.
 // ------------------------------------------------------------
  If cMask <> "A"
 	 oQR:SelectMask(Val(cMask))
   else
	 oQR:SelectMask()
  EndIf

 // -- Exporta para um BITMAP monocromatico.
 // -- Margem minima = 4 modulos (de cada lado).
 // -------------------------------------------- 
  oBMP := ZBITMAP():NEW(oQR:nSize+8, oQR:nSize+8, 1)

 // -- Plota os módulos setados com 1 
 // -- com a cor preta no Bitmap.
 // ---------------------------------
  For nX := 1 to oQR:nSize
	  For nY := 1 to oQR:nSize
		  If oQR:aGrid[nX][nY] == 1 .or. oQR:aGrid[nX][nY] == 3
			 oBMP:SetPixel(nX + 3, nY + 3, 0)
		  EndIf
	  Next
  Next

 // -- Gera a imagem em disco.
 // -- Cria um arquivo temporario com nome unico para 
 // -- driblar o cache de imagem da interface.
 // -------------------------------------------------
  cFile := "\qrtmp_" + cValToChar(Seconds()) + ".bmp"

  oBMP:SaveToBmp(cFile)

 // -- Redimensiona a imagem na tela com o tamanho da
 // -- versão escolhida + margens.
 // -------------------------------------------------
  oBmpQRCode:nWidth   := (oQR:nSize + 8) * MODULE_PIXEL_SIZE 
  oBmpQRCode:nHeight  := (oQR:nSize + 8) * MODULE_PIXEL_SIZE
  oBmpQRCode:lStretch := .T.
  
  oBMPQRCode:Load(,cFile)   // Carrega a imagem gerada na interface

  FErase(cFile)             // Apaga a imagem temporária do disco 
  FreeObj(oBmp)             // Limpa a classe bitmap da memoria 
Return

//---------------------------------------
/*/ Classe LCLASQRC
  Método : ExportImg
  
    Exporta o QR Code para imagem BITMAP.

  @author Anderson Almeida (TOTVS NE)
  @since 11/07/2023	
/*/
//---------------------------------------
//Method Export(oQr) Class LCLASORC
//Return
/*
Method ExportImg(oQR) Class LCLASORC
  Local nX       := 0
  Local nY       := 0
  Local nX1      := 0
  Local nX2      := 0
  Local nY1      := 0
  Local nY2      := 0
  Local nImgSize := 0
  Local cFile    := ""
  Local lRet := .T.
  Local oBmp     
/*
  nImgSize := (oQR:nSize + 8) * MODULE_PIXEL_SIZE

 oBMP := ZBITMAP():New(nImgSize, nImgSize, 1)
  
  oBMP:nPenSize := 1

 // -- Plota os módulos setados com 1 com quadrados vazados
 // -- no Bitmap e pinta o interior dos quadrados.
 // -------------------------------------------------------
  For nX := 1 To oQR:nSize
	  For nY := 1 To oQR:nSize
		  If oQR:aGrid[nX][nY] == 1 .or. oQR:aGrid[nX][nY] == 3
		     nX1 := (nX + 2) * MODULE_PIXEL_SIZE
		     nY1 := (nY + 2) * MODULE_PIXEL_SIZE
		     nX2 := nX1 + MODULE_PIXEL_SIZE
		     nY2 := nY1 + MODULE_PIXEL_SIZE

			 oBMP:Rectangle(nX1, nY1, nX2, nY2, 0)
			 oBMP:Paint(nX1 + 1, nY1 + 1)
		  EndIf
	  Next
  Next
 // ------------------------------------------------------- 	

  cFile := "\QRCode.bmp"

  oBMP:SaveToBmp(cFile)  // Salva o arquivo em disco

  FreeObj(oBMP)
*/
//  MsgInfo("Imagem do QR Code exportada para o arquivo [" + cFile + "]")
//Return lRet

