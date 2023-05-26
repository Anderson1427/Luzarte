#Include "PROTHEUS.ch"
#Include "FWMVCDef.ch"
#Include "TopConn.CH"
#Include "fileio.ch"

// --------------------------------------------------
/*/ Rotina LFISR001
  
   Importar XML (CTE).

  @author Anderson Almeida - TOTVS Ne
  Retorno
  @historia
   18/05/2023 - Desenvolvimento da Rotina.
/*/
// --------------------------------------------------
User Function LFISR001()
  Local aCampos := {}

  Private cMemoXML := ""
  Private aButtons := {{.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,"Confirmar"},;
                       {.T.,"Fechar"},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil}}

 // -- Criar tabela temporária
 // -- Cabeçalho
 // --------------------------
  aAdd(aCampos,{"T1_CHAVE","C",1,0})

  oTempTRB1 := FWTemporaryTable():New("TRB1")
  oTempTRB1:SetFields(aCampos)
  oTempTRB1:AddIndex("01",{"T1_CHAVE"})
  oTempTRB1:Create()

  aCampos := {}

  aAdd(aCampos,{"T2_CHAVE" ,"C",1,0})
  aAdd(aCampos,{"T2_NOMARQ","C",65,0})
  aAdd(aCampos,{"T2_DATA"  ,"D",8,0})
  aAdd(aCampos,{"T2_HORA"  ,"C",8,0})
  aAdd(aCampos,{"T2_STATUS","L",1,0})

  oTempTRB2 := FWTemporaryTable():New("TRB2")
  oTempTRB2:SetFields(aCampos)
  oTempTRB2:AddIndex("01",{"T2_CHAVE","T2_NOMARQ"})
  oTempTRB2:Create()

  aCampos := {}

  aAdd(aCampos,{"T3_CHAVE" ,"C",1,0})
  aAdd(aCampos,{"T3_NOMARQ","C",65,0})
  aAdd(aCampos,{"T3_DATA"  ,"D",8,0})
  aAdd(aCampos,{"T3_HORA"  ,"C",8,0})

  oTempTRB3 := FWTemporaryTable():New("TRB3")
  oTempTRB3:SetFields(aCampos)
  oTempTRB3:AddIndex("01",{"T3_CHAVE","T3_NOMARQ"})
  oTempTRB3:Create()

  aCampos := {}

  aAdd(aCampos,{"T4_CHAVE" ,"C",1,0})
  aAdd(aCampos,{"T4_SEQ"   ,"C",2,0})
  aAdd(aCampos,{"T4_STATUS","C",15,0})
  aAdd(aCampos,{"T4_NOMARQ","C",65,0})
  aAdd(aCampos,{"T4_DATA"  ,"D",8,0})
  aAdd(aCampos,{"T4_HORA"  ,"C",8,0})
  aAdd(aCampos,{"T4_MENSAG","C",250,0})

  oTempTRB4 := FWTemporaryTable():New("TRB4")
  oTempTRB4:SetFields(aCampos)
  oTempTRB4:AddIndex("01",{"T4_CHAVE","T4_SEQ"})
  oTempTRB4:Create()

  FWExecView("Importar","LFISR001",MODEL_OPERATION_INSERT,,{|| .T.},,,aButtons)

  oTempTRB1:Delete() 
  oTempTRB2:Delete() 
  oTempTRB3:Delete() 
  oTempTRB4:Delete() 
Return

// -----------------------------------------
/*/ Função ModelDef

   Define as regras de negocio.

  @author Totvs Nordeste
  Return
  @Since  28/04/2023
/*/
// -----------------------------------------
Static Function ModelDef() 
  Local oModel
  Local oStrCab as Object
  Local oStrTRB2 := fnM01TB2()
  Local oStrTRB3 := fnM01TB3()
  Local oStrTRB4 := fnM01TB4()

  oStrCab := FWFormModelStruct():New()

  oStrCab:AddTable("",{"XXTABKEY"},"XML (CTE)",{|| ""})
  oStrCab:AddField("Chave","Campo de texto","T1_CHAVE","C",1)
  
//  oModel:AddGrid("DETLOT","DETPED",oStruLot,bPreVld,bLinPost,bLinPost)  
  oModel := MPFormModel():New("Importar XML (CTE)")  

  oModel:SetDescription("Importar XML")

  oModel:AddFields("MSTCAB",,oStrCab)
 
  oModel:AddGrid("DETREC","MSTCAB",oStrTRB2)
  oModel:AddGrid("DETPRO","MSTCAB",oStrTRB3)
  oModel:AddGrid("DETHIS","MSTCAB",oStrTRB4)

  oModel:SetPrimaryKey({"T1_CHAVE"})

  oModel:SetRelation("DETREC",{{"T2_CHAVE","T1_CHAVE"}}, TRB2->(IndexKey(1)))
  oModel:SetRelation("DETPRO",{{"T3_CHAVE","T1_CHAVE"}}, TRB3->(IndexKey(1)))
  oModel:SetRelation("DETHIS",{{"T4_CHAVE","T1_CHAVE"}}, TRB4->(IndexKey(1)))
Return oModel

// -----------------------------------------
/*/ Função fnGerBor

   Gerar Bordero.

  @author Totvs Nordeste
  Return
  @Since  28/04/2023
/*/
// -----------------------------------------
Static Function fnGerBor(oModel)
  Local lRet    := .T.
//  Local oGrdBco := oModel:GetModel("DETREC")
 
  MsExecAuto({|a,b| (a,b)},3,{aRegBor, aRegTit})

  If lMsErroAuto
     MostraErro()
  EndIf
Return lRet

//-------------------------------------------
/*/ Fun��o fnM01TB2()

  Estrutura do detalhe da pasta Recebidas.							  

  @author Anderson Almeida (TOTVS NE)
  @since	28/04/2023	
/*/
//--------------------------------------------
Static Function fnM01TB2()
  Local oStruct := FWFormModelStruct():New()

  oStruct:AddTable("TRB2",{"T2_CHAVE","T2_NOMARQ"},"Recebidas")
  oStruct:AddField("Chave" ,"Chave","T2_CHAVE"  ,"C",1,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("XML"   ,"XML"  ,"T2_NOMARQ" ,"C",65,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Data"  ,"Data" ,"T2_DATA"   ,"D",8,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Hora"  ,"Hora" ,"T2_HORA"   ,"C",8,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Status","Status","T2_STATUS","L",1,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
Return oStruct

//-------------------------------------------
/*/ Fun��o fnM01TB3()

  Estrutura do detalhe da pasta Processados.							  

  @author Anderson Almeida (TOTVS NE)
  @since	28/04/2023	
/*/
//--------------------------------------------
Static Function fnM01TB3()
  Local oStruct := FWFormModelStruct():New()

  oStruct:AddTable("TRB3",{"T3_CHAVE","T3_NOMARQ"},"Processadas")
  oStruct:AddField("Chave","Chave","T3_CHAVE" ,"C",01,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("XML"  ,"XML"  ,"T3_NOMARQ","C",65,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Data" ,"Data" ,"T3_DATA"  ,"D",08,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Hora" ,"Hora" ,"T3_HORA"  ,"C",08,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
Return oStruct

//-------------------------------------------
/*/ Fun��o fnM01TB4()

  Estrutura do detalhe dos Hist�rico.							  

  @author Anderson Almeida (TOTVS NE)
  @since	28/04/2023	
/*/
//--------------------------------------------
Static Function fnM01TB4()
  Local oStruct := FWFormModelStruct():New()

  oStruct:AddTable("TRB4",{"T4_CHAVE","T4_SEQ"},"Historico")
  oStruct:AddField("Chave"    ,"Chave"    ,"T4_CHAVE" ,"C",01,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Sequencia","Sequencia","T4_SEQ"   ,"C",02,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField(""         ,""         ,"T4_STATUS","C",15,0,Nil,Nil,{},.F.,,.F.,.F.,.T.)
  oStruct:AddField("XML"      ,"XML"      ,"T4_NOMARQ","C",65,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Data"     ,"Data"     ,"T4_DATA"  ,"D",08,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Hora"     ,"Hora"     ,"T4_HORA"  ,"C",08,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Mensagem" ,"Mensagem" ,"T4_MENSAG","C",250,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
Return oStruct

//--------------------------------------
/*/ Fun��o ViewDef()
  
    Defini��o da View

  @author Anderson Almeida (TOTVS NE)
  @since	28/04/2023	
/*/
//---------------------------------------
Static Function ViewDef() 
  Local oModel   := ModelDef() 
  Local oStrTRB1 := fnV01TB1()
  Local oStrTRB2 := fnV01TB2()
  Local oStrTRB3 := fnV01TB3()
  Local oStrTRB4 := fnV01TB4()
  Local oView

  oView := FWFormView():New() 
   
  oView:SetModel(oModel)
  oView:AddOtherObject("FXML", {|oPanel| fnCriaMem(oPanel)})
  oView:AddOtherObject("FBOT", {|oPanel| fnCriaBut(oPanel)})

  oView:AddField("FCAB",oStrTRB1,"MSTCAB") 
  oView:AddGrid("FREC" ,oStrTRB2,"DETREC") 
  oView:AddGrid("FPRO" ,oStrTRB3,"DETPRO") 
  oView:AddGrid("FHIS" ,oStrTRB4,"DETHIS") 

  oView:SetViewProperty("FREC","GRIDDOUBLECLICK",{{|oGrid,cField,nLGrid,nLModel| fnDbClick(oGrid,cField,nLGrid,nLModel)}})

  oView:EnableTitleView("FREC","Recebidos") 
  oView:EnableTitleView("FPRO","Processados") 
  oView:EnableTitleView("FHIS","Historicos") 
  oView:EnableTitleView("FXML","XML") 

 // --- Defini��o da Tela
 // ---------------------
  oView:CreateHorizontalBox("BXSUP",0)
  
  oView:CreateHorizontalBox("BXARQ",45) 
  oView:CreateVerticalBox("VREC",50,"BXARQ")  
  oView:CreateVerticalBox("VPRO",50,"BXARQ")  
  
  oView:CreateHorizontalBox("BXINF",45)  
  oView:CreateVerticalBox("VHIS",50,"BXINF")
  oView:CreateVerticalBox("VXML",50,"BXINF")

  oView:CreateHorizontalBox("BXROD",10)  

 // --- Defini��o dos campos
 // ------------------------    
  oView:SetOwnerView("FCAB","BXSUP")
  oView:SetOwnerView("FREC","VREC")
  oView:SetOwnerView("FPRO","VPRO")
  oView:SetOwnerView("FHIS","VHIS")
  oView:SetOwnerView("FXML","VXML")
  oView:SetOwnerView("FBOT","BXROD")

  oView:SetViewAction("ASKONCANCELSHOW",{|| .F.})           // Tirar a mensagem do final "H� Altera��es n�o..."
  oView:SetAfterViewActivate({|oView| fnLerRec(oView)})     // Carregar dados antes de montar a tela
  oView:ShowInsertMsg(.F.)
Return oView

//---------------------------------------
/*/ Fun��o fnCriaMem

    Cria campo Memo.

  @param oPanel = campo ser� mostrado
  @author Anderson Almeida (TOTVS NE)
  @since	23/11/2020	
/*/
//---------------------------------------
Static Function fnCriaMem(oPanel)
  oTMultiGet := TMultiget():New(01,01, {|u| If(pCount() > 0, cMemoXML := u, cMemoXML)},oPanel,320,105,,,,,,.F.,,,,,,.T.)
Return

//---------------------------------------
/*/ Fun��o fnCriaBut

    Cria bot�o.

  @param oPanel = campo ser� mostrado
  @author Anderson Almeida (TOTVS NE)
  @since	23/11/2020	
/*/
//---------------------------------------
Static Function fnCriaBut(oPanel)
  TButton():New(003,610,"Importar",oPanel,{|| MsAguarde({|| fnImportar()},"Gerando...")},40,13,,,.F.,.T.,.F.,,.F.,,,.F.)
Return

//-------------------------------------------------
/*/ Fun��o fnDbClick

   Dublo click no grid. Ler XML

  @Par�metro: oGrid = Objecto Grid
              cField = nome do campo
              nLGrid = Linha do grid
              nLModel = Linha do grid
  @author Anderson Almeida (TOTVS NE)
  @since  25/05/2023	
/*/
//--------------------------------------------------
Static Function fnDbClick(oGrid,cField,nLGrid,nLModel)
  Local cXMLOri := "C:\XML\" + AllTrim(oGrid:GetModel("FREC"):GetValue("T2_NOMARQ"))
  Local nHandle := 0
  Local nLength := 0
  
  If cField == "T2_NOMARQ"
   	 nHandle := FOpen(cXMLOri)
	   nLength := FSeek(nHandle,0,FS_END)

	   FSeek(nHandle,0)

	   If nHandle > 0
		    FRead(nHandle, cXMLOri, nLength)
		    FClose(nHandle)
			
		    If ! Empty(cXMLOri)
				   cMemoXML := DecodeUTF8(cXMLOri)
				   cMemoXML := A140IRemASC(cMemoXML)	//remove caracteres especiais n�o aceitos pelo encode
		    EndIf
	   EndIf
  EndIf 
Return .T. 

//-------------------------------------------
/*/ Fun��o fnV01TB1

   Estrutura do detalhe do Cabe�alho (View)
  						  
  @author Anderson Almeida (TOTVS NE)
  @since  18/05/2023
/*/
//-------------------------------------------
Static Function fnV01TB1()
  Local oViewTB := FWFormViewStruct():New() 

 // -- Montagem Estrutura
 //      01 = Nome do Campo
 //      02 = Ordem
 //      03 = T��tulo do campo
 //      04 = Descri��o do campo
 //      05 = Array com Help
 //      06 = Tipo do campo
 //      07 = Picture
 //      08 = Bloco de PictTre Var
 //      09 = Consulta F3
 //      10 = Indica se o campo � alter�vel
 //      11 = Pasta do Campo
 //      12 = Agrupamnento do campo
 //      13 = Lista de valores permitido do campo (Combo)
 //      14 = Tamanho m�ximo da op��o do combo
 //      15 = Inicializador de Browse
 //      16 = Indica se o campo � virtual (.T. ou .F.)
 //      17 = Picture Variavel
 //      18 = Indica pulo de linha ap�s o campo (.T. ou .F.)
 // --------------------------------------------------------
  oViewTB:AddField("T1_CHAVE","01","Chave","XML (CTE)",Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
Return oViewTB

//-------------------------------------------
/*/ Função fnV01TB2

   Estrutura do detalhe do Grid (View)
   Recebidas						  
  @author Anderson Almeida (TOTVS NE)
  @since  18/05/2023
/*/
//-------------------------------------------
Static Function fnV01TB2()
  Local oViewTB := FWFormViewStruct():New() 

  oViewTB:AddField("T2_STATUS","01",""    ,""    ,Nil,"L",""  ,Nil,"",.T.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewTB:AddField("T2_NOMARQ","02","XML" ,"XML" ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil,450)
  oViewTB:AddField("T2_DATA"  ,"03","Data","Data",Nil,"D","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewTB:AddField("T2_HORA"  ,"04","Hora","Hora",Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
Return oViewTB

//-------------------------------------------
/*/ Função fnV01TB3

   Estrutura do detalhe do Grid (View)
   Processadas					  
  @author Anderson Almeida (TOTVS NE)
  @since  28/04/2023
/*/
//-------------------------------------------
Static Function fnV01TB3()
  Local oViewTB := FWFormViewStruct():New() 

  oViewTB:AddField("T3_NOMARQ","01","XML" ,"XML" ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil,450)
  oViewTB:AddField("T3_DATA"  ,"02","Data","Data",Nil,"D","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewTB:AddField("T3_HORA"  ,"03","Hora","Hora",Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
Return oViewTB

//-------------------------------------------
/*/ Função fnV01TB4

   Estrutura do detalhe do Grid (View)
   Historico						  
  @author Anderson Almeida (TOTVS NE)
  @since  18/05/2023
/*/
//-------------------------------------------
Static Function fnV01TB4()
  Local oViewTB := FWFormViewStruct():New() 

  oViewTB:AddField("T4_STATUS","00",""        ,""        ,{"Legenda"},"C","@BMP",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewTB:AddField("T4_NOMARQ","01","XML"     ,"XML"     ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewTB:AddField("T4_DATA"  ,"02","Data"    ,"Data"    ,Nil,"D","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewTB:AddField("T4_HORA"  ,"03","Hora"    ,"Hora"    ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewTB:AddField("T4_MENSAG","04","Mensagem","Mensagem",Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
Return oViewTB

//-------------------------------------------------
/*/ Função fnLerBco

   Carregar nome dos arquivos XML.

  @Parâmetro: oView = Objecto View
  @author Anderson Almeida (TOTVS NE)
  @since  18/05/2023	
/*/
//--------------------------------------------------
Static Function fnLerRec(oView)
  Local oModel  := FwModelActive()
  Local oGrdRec := oModel:GetModel("DETREC")
  Local aFiles  := {}
  Local nX      := 0

  aFiles := Directory("C:\XML\" + "*.XML")

  For nX := 1 To Len(aFiles)
      oGrdRec:AddLine()

      oGrdRec:SetValue("T2_NOMARQ", aFiles[nX][01])
      oGrdRec:SetValue("T2_DATA"  , aFiles[nX][03])
      oGrdRec:SetValue("T2_HORA"  , aFiles[nX][04])
  Next

  oGrdRec:GoLine(1)
  oView:Refresh()
Return

//---------------------------------------
/*/ Fun��o fnImportar

    Importar os XMLs selecionados.

  @author Anderson Almeida (TOTVS NE)
  @since	26/05/2023	
/*/
//---------------------------------------
Static Function fnImportar()
  Local oModel   := FwModelActive()
  Local oGrdRec  := oModel:GetModel("DETREC")
  Local oXml     := Nil
  Local nX       := 0
  Local cArqOrig := ""
  Local cError   := ""
  Local cWarning := ""
  Local cEmissao := ""
  Local aErro    := {}
  Local aRegSF2  := {}
  Local aREgSD2  := {}

  dbSelectArea("SA1")
  SA1->(dbSetOrder(3))            

  For nX := 1 To oGrdRec:Length()
      oGrdRec:GoLine(nX)

      If ! oGrdRec:GetValue("T2_STATUS")
         Exit
      EndIf

      cArqOrig := AllTrim(oGrdRec:GetValue("T2_NOMARQ"))

      __CopyFile("C:\XML\" + cArqOrig,"xmlcte\recebidos\" + cArqOrig)
	    
      oXml := XmlParserFile("xmlcte\recebidos\" + cArqOrig, "_", @cError, @cWarning)

	    If XMLError() <> 0 .Or. ! Empty(cError)
		     If ! Empty(cError)
			      aAdd(aErro,{cArqOrig, cError})		
		      else
			      aAdd(aErro,{cArqOrig,"Problemas no arquivo " + cArqOrig + " XML"})
		    EndIf

   	    Loop
		  EndIf
      
     // -- Execuato MATA920 - Nota Fiscal Sa�da
     // -- M�dulo - Livros Fiscais
     // ---------------------------------------
      cEmissao := Substr(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:Text,1,4) +;
                  SubStr(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_DHEMI:Text,6,2) +;
                  Substr(oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:Text,9,2)

      If ! SA1->(dbSeek(FWxFilial("SA1") + oXml:_CTEPROC:_CTE:_INFCTE:_RECEB:_CNPJ:Text))
         aAdd(aErro, {cArqOrig, "Fornecedor n�o cadastrado CNPJ - " +;
                                oXml:_CTEPROC:_CTE:_INFCTE:_RECEB:_CNPJ:Text})
         Loop
      EndIf

     // -- Cabe�alho Nota
     // ----------------- 
      aAdd(aRegSF2, {"F2_TIPO"   , "N"})
      aAdd(aRegSF2, {"F2_FORMUL" , "N"})
      aAdd(aRegSF2, {"F2_DOC"    , oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_NCT:Text})
      aAdd(aRegSF2, {"F2_SERIE"  , oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:Text})
      aAdd(aRegSF2, {"F2_EMISSAO", SToD(cEmissao)})
      aAdd(aRegSF2, {"F2_CLIENTE", SA1->A1_COD})
      aAdd(aRegSF2, {"F2_TIPOCLI", SA1->A1_TIPO})
      aAdd(aRegSF2, {"F2_LOJA"   , SA1->A1_LOJA})
      aAdd(aRegSF2, {"F2_ESPECIE", "CTE"})
      aAdd(aRegSF2, {"F2_COND"   , SA1->A1_COND})
      aAdd(aRegSF2, {"F2_VALBRUT", Val(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:Text)})
      aAdd(aRegSF2, {"F2_VALFAT" , Val(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:Text)})      
      aAdd(aRegSF2, {"F2_PREFIXO", oXml:_CTEPROC:_CTE:_INFCTE:_IDE:_SERIE:Text})
          
     // -- Item Nota
     // ------------
      aAdd(aRegSD2, {"D2_ITEM"  , StrZero(1,TamSX3("D2_ITEM")[1]) ,Nil})
      aAdd(aRegSD2, {"D2_COD"   , "90010001000001"                ,Nil})
      aAdd(aRegSD2, {"D2_QUANT" , 1                               ,Nil})
      aAdd(aRegSD2, {"D2_PRCVEN", Val(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:Text),Nil})
      aAdd(aRegSD2, {"D2_TOTAL" , Val(oXml:_CTEPROC:_CTE:_INFCTE:_VPREST:_VTPREST:Text),Nil})
      aAdd(aRegSD2, {"D2_TES"   , "504"                           ,Nil})
      aAdd(aLinha,{"D2_CF","5102",Nil})
          
            
aadd(aItensT,aLinha)
          aLinha := {}
          aadd(aLinha,{"D2_ITEM" ,"02",Nil})
          aadd(aLinha,{"D2_COD" ,"000032",Nil})
          aadd(aLinha,{"D2_QUANT",2,Nil})
          aadd(aLinha,{"D2_PRCVEN",45,Nil})
          aadd(aLinha,{"D2_TOTAL",90,Nil})
          aadd(aLinha,{"D2_TES","501",Nil})
          aadd(aLinha,{"D2_CF","5102",Nil})
          
          
          
aadd(aItensT,aLinha)
          
MSExecAuto({|x,y,z| mata920(x,y,z)},aCabec,aItensT,3) //Inclusao

alert("Nota inserida!!!")   

*/

  Next
Return