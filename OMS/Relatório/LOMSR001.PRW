#Include "PROTHEUS.ch"
#Include "TopConn.ch"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"

#define MODULE_PIXEL_SIZE  12   // Tamanho em PIXELs do Modulo

// -------------------------------------------
/*/ Rotina LOMSR001
 
     Impressão etiquetas de conferência.

  @author Totvs Nordeste
  @history
    21/07/2023 - Desenvolvimento da Rotina.
/*/
// --------------------------------------------
User Function LOMSR001()
  Private cPorta  := "LPT1"            // Porta da impressora informada no parametro
  Private cModelo := "ZEBRA"
  Private cPerg   := "LOMSR001"
  Private oQrCode

  fnCriaPrg()

  If Pergunte(cPerg,.T.)
     Processa({|lEnd| fnImpEtiq() },"Aguarde...","Gerando Etiqueta de Conferência...",.F.)
  EndIf
Return

//-------------------------------------------
/*/ Função fnImpEtiq()

    Etiquetas de Conferência
  						  
  @Parametro: nCarga,nRadAux,cEditAux
  @author Anderson Almeida (TOTVS NE)
  @since   21/07/2023
/*/
//-------------------------------------------
Static Function fnImpEtiq(_nTipo,_aProd,_cCodTab)
  Local nX       := 0
  Local nFxFinal := 0
  Local cQuery   := ""
  Local aRegImp  := {}

  cQuery := "Select DAK.DAK_COD, DAI.DAI_PEDIDO, DAI.DAI_SEQCAR, SC9.C9_QTDLIB,"
  cQuery += "       SC9.C9_ITEM, SB1.B1_DESC, SB1.B1_CODBAR"
  cQuery += " from " + RetSqlName("DAK") + " DAK," + RetSqlName("DAI") + " DAI,"
  cQuery += RetSqlName("SC9") + " SC9, " + RetSqlName("SB1") + " SB1"
  cQuery += "  where DAK.D_E_L_E_T_ <> '*'"
  cQuery += "    and DAK.DAK_FILIAL = '" + FWxFilial("DAK") + "'"
  cQuery += "    and DAK.DAK_COD between '" + MV_PAR01 + "' and '" + MV_PAR02 + "'"
  cQuery += "    and DAI.D_E_L_E_T_ <> '*'"
  cQuery += "    and DAI.DAI_FILIAL = '" + FWxFilial("DAI") + "'"
  cQuery += "    and DAI.DAI_COD    = DAK.DAK_COD"
  cQuery += "    and DAI.DAI_PEDIDO between '" + MV_PAR03 + "' and '" + MV_PAR04 + "'"
  cQuery += "    and SC9.D_E_L_E_T_ <> '*'"
  cQuery += "    and SC9.C9_FILIAL  = '" + FWxFilial("SC9") + "'"
  cQuery += "    and SC9.C9_PEDIDO  = DAI.DAI_PEDIDO"
  cQuery += "	   and SC9.C9_CARGA   = DAI.DAI_COD"
  cQuery += "	   and SC9.C9_SEQCAR  = DAI.DAI_SEQCAR"
  cQuery += "	   and SC9.C9_SEQENT  = DAI.DAI_SEQUEN"
  cQuery += "    and SB1.D_E_L_E_T_ <> '*'"
  cQuery += "    and SB1.B1_FILIAL  = '" + FWxFilial("SB1") + "'"
  cQuery += "    and SB1.B1_COD     = SC9.C9_PRODUTO"
  cQuery += "  Order by DAK.DAK_COD, DAI.DAI_PEDIDO, DAI.DAI_SEQCAR"
  cQuery := ChangeQuery(cQuery)
  dbUseArea(.T.,"TopConn",TCGenQry(,,cQuery),"QTMP",.F.,.T.)

  If QTMP->(Eof())
     Aviso("ATENÇÃO","Não existe registro(s) com esses parâmetros.",{"OK"})

     QTMP->(dbCloseArea())
     Return              
  EndIf

  While ! QTMP->(Eof())
    If QTMP->C9_QTDLIB > MV_PAR06
	     nFxFinal := MV_PAR06
	   else
	     nFxFinal := QTMP->C9_QTDLIB
	  EndIf		  

    For nX := MV_PAR05 To nFxFinal
	      aAdd(aRegImp, {QTMP->DAK_COD,;               // 01 - Carga
		      	           QTMP->DAI_SEQCAR,;            // 02 - Sequêncial da Carga
	                     QTMP->DAI_PEDIDO,;            // 03 - Pedido
			                 QTMP->C9_ITEM,;               // 04 - Item do pedido
			                 QTMP->B1_DESC,;               // 05 - Descrição do Produto
	      			         QTMP->B1_CODBAR,;             // 06 - Código de barra do produto
				               nX,;                          // 07 - Número inicial
                       nFxFinal})                    // 08 - Número Final
	  Next

    QTMP->(dbSkip())
  EndDo

  QTMP->(dbCloseArea())

  fnEtiqueta(@aRegImp)
Return

//-------------------------------------------
/*/ Função fnEtiqueta()

    Imprimir Etiquetas de Conferência
  						  
  @author Anderson Almeida (TOTVS NE)
  @since   21/07/2023
/*/
//-------------------------------------------
Static Function fnEtiqueta(aRegImp)
  Local nX := 0

  MSCBPRINTER(cModelo,cPorta,,76.8,.F.,,,,,,.F.,)
  MSCBCHKSTATUS(.F.)
  MSCBLoadGraf("\GRF\LOGO.GRF")

	For nX := 1 to len(aRegImp)
      MSCBBEGIN(1,6) 
      MSCBWrite("^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR6,6~SD30^JUS^LRN^CI0^XZ")
      MSCBWrite("^XA")
      MSCBWrite("^MMT")
      MSCBWrite("^PW823")
      MSCBWrite("^LL0304")

      MSCBSAY(05,01,"Conferência","N","A","025,014") 
      
      MSCBWrite("^FO0,0^GFA,07168,07168,00028,:Z64:")
      MSCBWrite("eJzt1s1q3DAQAOBxXVBPnRcI1ouI9Wv5YGKFHvoW7as45NC3aAU99FgfdVhWGdnaTboz44bQHgIaMCx8a0sa/Q1AjRo1atSoUeNNRLuo9N5E1frPJ91SUm1K6DUbkpk1c32r2uFjGzS7hUazNsl2oAdPorWJOoFRNEyUSQui9ekI0JEJCU2/KJOWXjoyak4wkaVAw2BdiWA9NToDT7YJgDM0aW6SZ92cIWcZvTDx1PucSQQh15SVZh2gYCM9MQ9QmIdhezopL3F71wGwvuS2MogWtv647et/xNqDTrHcc5vtRjbM3bFsjozP5uk9xczfDMO1YWnUAd8PT2ZUO2hGyemA76PuYnz+ir2zwvxttrS4zQg3IPPAxn426olm5lNYV45gg3kI6z6UDO+X8vNZ3BQLMc+waHa53VLEv+ns0qvmovUs2cXGEYNih2E0UTG7DM2JTdLFID3IhmGAXrM5Aipm/ALNz2s7D3gBviheYHkb/jMricrG8lIsv2N3bLq20kibj0KvmmHnbjH6NMpnz2r9dXPPbLqm8ylGdjKK0RaLbA1erF3Ymi8nHIIJ3MazzWwf5cMR8tJA75gdilm+N8ti6ug//B6zF+P3ChYb+RlSJrCDKNwd20pwEIW6oF0vPtcsKFigu48sWM+MzjK6qF0bekb5TPp9JJul2ibiXSK759c0JRthCs58k2qpA4I9OvM1CNbT/JAlPgRK6BcqCZRSCr/niihJXQHzgyq3PknN5ZKHGpUrt9X4elij2THIe0uzKRtfnGvkDeT44lwjT6pTPmqCbu2O5YXZaTbs2Icdo+j4RnmRWVaEPAW+1vSKHXaq+Vdb+x+sRo0aNWrUqPGG4hGt8fzD:385E")
      MSCBWrite("^FO384,0^GFA,08192,08192,00032,:Z64:") 

      MSCBGrafic(10,08,"LOGO")
      MSCBSAY(30,07,"Carga","N","A","025,012") 
      MSCBSAY(45,07,"Sequencia","N","A","025,012") 
      MSCBSAY(70,07,"Pedido","N","A","025,012") 
      
      MSCBSAY(90,07,"Item","N","A","025,012") 
 
      MSCBSAY(30,12,aRegImp[nX][01],"N","A","025,012") 
      MSCBSAY(45,12,aRegImp[nX][02],"N","A","025,012") 
      MSCBSAY(70,12,aRegImp[nX][03],"N","A","025,012") 
      MSCBSAY(90,12,aRegImp[nX][04],"N","A","025,012") 

      MSCBSAY(25,22,Substr(aRegImp[nX][05],1,50),"N","A","025,012") 
      MSCBSAY(25,32,Substr(aRegImp[nX][05],51,50),"N","A","025,012") 

      MSCBSAYBAR(07,35,aRegImp[nX][01] + aRegImp[nX][03] + aRegImp[nX][04] +;
                       AllTrim(Str(aRegImp[nX][07])),"N","MB01",7,.F.,.T.,.F.,,2,2)   // Codigo de Barras

      MSCBSAYBAR(70,35,aRegImp[nX][6],"N","MB04",7,.F.,.T.,.F.,,2,2)   // Codigo de Barras

  	  MSCBSAY(05,47,DToC(dDataBase),"N","A","014,012")
  	  MSCBSAY(90,47,AllTrim(Str(aRegImp[nX][07])) + "/" + AllTrim(Str(aRegImp[nX][08])),"N","A","014,012")

      MSCBEND()     
	Next
  
  MSCBCLOSEPRINTER()		
Return

//-------------------------------------------
/*/ Função fnCriaPrg()

    Cria perguntas
  						  
  @author Anderson Almeida (TOTVS NE)
  @since   27/07/2023
/*/
//-------------------------------------------
Static Function fnCriaPrg()
  Local _sAlias := Alias()
  Local aRegs   := {}
  Local nX      := 0
  Local nY      := 0

  dbSelectArea("SX1")
  SX1->(dbSetOrder(1))

  aAdd(aRegs,{cPerg,"01","Carga De ?"  ,"","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","DAK"})
  aAdd(aRegs,{cPerg,"02","Carga Até ?" ,"","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","DAK"})
  aAdd(aRegs,{cPerg,"03","Pedido De ?" ,"","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","SC5"})  
  aAdd(aRegs,{cPerg,"04","Pedido Até ?","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","SC5"})
  aAdd(aRegs,{cPerg,"05","Faixa De ?"  ,"","","mv_ch5","N",04,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})  
  aAdd(aRegs,{cPerg,"06","Faixa Até ?" ,"","","mv_ch6","N",04,0,0,"G","","mv_par06","","","","9999","","","","","","","","","","","","","","","","","","","","","",""})

  For nX := 1 To Len(aRegs)
	    If ! SX1->(dbSeek(PadR(cPerg,10) + aRegs[nX][02]))
		     RecLock("SX1",.T.)
		       For nY := 1 To FCount()
		           If nY <= Len(aRegs[nX])
			            FieldPut(nY,aRegs[nX][nY])
			         EndIf
		       Next
		     SX1->(MsUnlock())
	    EndIf
  Next

  dbSelectArea(_sAlias)
Return
