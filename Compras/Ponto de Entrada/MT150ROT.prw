#Include "PROTHEUS.CH"

// -----------------------------------------------------------
/*/ Rotina MATA150 - Atualiza��o de Pre�os de Cota��o
  Fun��o MT150ROT

   Ponto de entrada para colocar op��o na A��es Relacionadas
   da tela de Atualiza��o de Cota��o 

  @author TOTVS Ne - Anderson
  @history
    12/05/2023 - Desenvolvimento da Rotina.
/*/
// -----------------------------------------------------------
User Function MT150ROT()
  aAdd(aRotina, {"Reenviar E-Mail - Fornecedor","U_ACOMW056(3,Nil,SC8->C8_NUM)",0,1,0,.F.})
Return aRotina
