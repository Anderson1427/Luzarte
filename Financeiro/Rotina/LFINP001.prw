#include "PROTHEUS.ch"
#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "Directry.ch"

// ---------------------------------------------------
/*/ Rotina LFINP001

    Importa��o do XML de CTE, gera��o dos registros 
    fiscais e financeiro (Contas a Receber).

 @author Anderson - TOTVS
 @history
   16/05/2023 - Desenvolvimento da Rotina.
/*/
// ----------------------------------------------------
User Function LFINP001(aParam)
  Local cEmp      := aParam[1] 
  Local cFil      := aParam[2]
  Local cQuery    := ""
  Local nX        := 0
  Local cBarras   := IIf(isSRVunix(),"/","\")
  Local cRootPath := AllTrim(GetSrvProfString("RootPath",cBarras))
  Local aFiles    := Directory(cRootPath + cBarras + "3lm_json" + cBarras + "\*.ctr","D")
  Local aNomeArq  := {}

   If IsBlind()      // Prepara��o do ambiente em caso de start via Job.
      RpcClearEnv()
      RpcSetType(3) 
      RPCSetEnv(cEmp,cFil,,,"FIN",,,,,,)
   EndIf
   
   //Mensagem de �nicio de Execu��o no Console
   ConOut("/*-------------------------------------------------------")
   ConOut("   Iniciou o processo de Importa��o do XML (CTE)")
   ConOut("   ---------------------------------------------")

  
  
  
  
  
  
   cQry := " Select SL1.L1_FILIAL, SL1.L1_NUM, SL1.L1_DOC, SL1.L1_SERIE, SL1.L1_EMISNF, SL1.L1_SITUA"
      cQry += " From " + RetSqlName("SL1") + " SL1"
      cQry += " WHERE SL1.D_E_L_E_T_ <> '*' "
      cQry += " AND L1_SITUA = 'ER' "
      cQry += " AND L1_ERGRVBT <> '' "
      cQry := ChangeQuery(cQry)
      IF Select("TMPSL1") > 0
       TMPSA1->(DbCloseArea())
      EndIf
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TMPSL1",.T.,.T.)

      TMPSL1->(dbGoTop())
      While !TMPSL1->(EoF())
         ConOut("Filial: "+TMPSL1->L1_FILIAL+;
                " / Orcamento: "+TMPSL1->L1_NUM+;
                " / Cupom: "+TMPSL1->L1_DOC+;
                " / Serie: "+TMPSL1->L1_SERIE+;
                " / Emis. NF: "+DToC(SToD(TMPSL1->L1_EMISNF))+;
                " / Situacao: "+TMPSL1->L1_SITUA)
       TMPSL1->(dbSkip())
      EndDo

  // -- Deletar registros com situa��o de 'ER' e j� processado, duplicidade
  // -----------------------------------------------------------------------
   cQry := "Select SL1.R_E_C_N_O_ as RECNOSL1, SL2.R_E_C_N_O_ as RECNOSL2, SL4.R_E_C_N_O_ as RECNOSL4"
   cQry += "  from " + RetSqlName("SL1") + " SL1, " + RetSqlName("SL2") + " SL2, " + RetSqlName("SL4") + " SL4"
   cQry += "   where SL1.D_E_L_E_T_ <> '*'"
   cQry += "     and SL1.L1_SITUA    = 'ER'"
   cQry += "     and SL1.L1_ERGRVBT <> ''"
	cQry += "     and exists (Select a.R_E_C_N_O_ as Recno"  
   cQry += "                    from " + RetSqlName("SL1") + " a" 
   cQry += "                     where a.D_E_L_E_T_ <> '*'"
   cQry += "                       and a.L1_SITUA   <> 'ER'"
   cQry += "   				        and a.L1_FILIAL  = SL1.L1_FILIAL"
	cQry += "    				        and a.L1_DOC     = SL1.L1_DOC"
	cQry += "          				  and a.L1_SERIE   = SL1.L1_SERIE"
	cQry += "         				  and a.L1_PDV     = SL1.L1_PDV"
	cQry += "   				        and a.L1_KEYNFCE = SL1.L1_KEYNFCE)"
   cQry += "     and SL2.D_E_L_E_T_ <> '*'"
   cQry += "     and SL2.L2_FILIAL  = SL1.L1_FILIAL"
   cQry += "     and SL2.L2_NUM     = SL1.L1_NUM"
   cQry += "     and SL4.D_E_L_E_T_ <> '*'"
   cQry += "     and SL4.L4_FILIAL  = SL1.L1_FILIAL"
   cQry += "     and SL4.L4_NUM     = SL1.L1_NUM"
   cQry := ChangeQuery(cQry)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QSL1",.T.,.T.)
   
   dbSelectArea("SL1")
   SL1->(dbSetOrder(1))

   dbSelectArea("SL2")
   SL2->(dbSetOrder(1))

   dbSelectArea("SL4")
   SL4->(dbSetOrder(1))

   While ! QSL1->(Eof())
     If nRecnoSL1 <> QSL1->RECNOSL1
        SL1->(dbGoto(QSL1->RECNOSL1))

        Reclock("SL1",.F.)
          dbDelete()
        SL1->(MsUnlock())

        nRecnoSL1 := QSL1->RECNOSL1
     EndIf

     If nRecnoSL2 <> QSL1->RECNOSL2
        SL2->(dbGoto(QSL1->RECNOSL2))

        Reclock("SL2",.F.)
          dbDelete()
        SL2->(MsUnlock())

        nRecnoSL2 := QSL1->RECNOSL2
     EndIf

     If nRecnoSL4 <> QSL1->RECNOSL4
        SL4->(dbGoto(QSL1->RECNOSL4))

        Reclock("SL4",.F.)
          dbDelete()
        SL4->(MsUnlock())

        nRecnoSL4 := QSL1->RECNOSL4
     EndIf

     QSL1->(dbSkip())
   EndDo

   QSL1->(dbCloseArea())

  // -- Verificar se existe arquivo de Controle preso 
  // ------------------------------------------------
   AEVAL(aFiles, {|file| aAdd(aNomeArq, file[F_NAME])})

   For nX := 1 To Len(aNomeArq)
       FErase(cRootPath + cBarras + "3lm_json" + cBarras + aNomeArq[nX])       // Deletar arquivo de controle
   Next  

  // -- Auditar o arquivo de log com a tabela de Nota para verificar
  // -- se realmente gravou a CT-e
  // ---------------------------------------------------------------
   dbSelectArea("SZ1")
   SZ1->(dbSetOrder(1))

   cQry := "Select SZ1.R_E_C_N_O_ as RECNOSZ1"
   cQry += "  from " + RetSqlName("SZ1") + " SZ1"
   cQry += "   where SZ1.D_E_L_E_T_ <> '*'"
   cQry += "     and SZ1.Z1_DATA between '" + DToS(dDataBase - 1) + "' and '" + DToS(dDataBase) + "'"
   cQry += "     and SZ1.Z1_ROTINA = 'MATA116'"
   cQry += "     and SZ1.Z1_STATUS = 'S'"
   cQry += "     and not exists (Select SF1.R_E_C_N_O_ from " + RetSqlName("SF1") + " SF1"
   cQry += "                        where SF1.D_E_L_E_T_ <> '*'"
	cQry += "   			              and SF1.F1_FILIAL  = SZ1.Z1_FILDEST"
	cQry += "  			                 and SF1.F1_DOC     = Substring(SZ1.Z1_DOCTO,22,9)"
	cQry += "          			        and SF1.F1_SERIE   = Substring(SZ1.Z1_DOCTO,11,3)"
	cQry += "  			                 and SF1.F1_FORNECE = Substring(SZ1.Z1_DOCTO,43,8)"
	cQry += "			                 and SF1.F1_LOJA    = Substring(SZ1.Z1_DOCTO,57,4))"
   cQry := ChangeQuery(cQry)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QSZ1",.T.,.T.)

   While ! QSZ1->(Eof())
     SZ1->(dbGoto(QSZ1->RECNOSZ1))

     Reclock("SZ1",.F.)
       Replace SZ1->Z1_MENSAG with "AUDITORIA - Registro n�o encontrado na tabela de Notas, processe novamente."
       Replace SZ1->Z1_STATUS with "E"
     SZ1->(MsUnlock())

     QSZ1->(dbSkip())
   EndDo

   QSZ1->(dbCloseArea())
  // --------------------

   TCLink()
      cQry := " UPDATE " + RetSqlName("SL1") 
      cQry += " SET L1_SITUA = 'RX', L1_ERGRVBT = NULL "
      cQry += " WHERE " 
      cQry += " D_E_L_E_T_ <> '*' "
      cQry += " AND L1_SITUA = 'ER' "
      cQry += " AND L1_ERGRVBT <> '' "
      
      //Executando Update
      nStatus := TCSqlExec(cQry)
      
      If (nStatus < 0)
         ConOut("Houve um erro na tentativa do Update." + CRLF + TCSQLError())
      endif
   TCUnlink()
  
  //Mensagem de fim de Execu��o no Console
  ConOut("                                                         ")
  ConOut("Finalizou o processo de atualizacao da tabela SL1")
  ConOut("/*-------------------------------------------------------")

  If (IsBlind()) //ENCERRAMENTO DE AMBIENTE EM CASO DE ESTADO DE JOB
      RpcClearEnv()
  Endif    

Return
