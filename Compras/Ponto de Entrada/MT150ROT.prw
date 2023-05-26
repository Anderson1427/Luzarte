#Include "PROTHEUS.CH"

// -----------------------------------------------------------
/*/ Rotina MATA150 - Atualização de Preços de Cotação
  Função MT150ROT

   Ponto de entrada para colocar opção na Ações Relacionadas
   da tela de Atualização de Cotação 

  @author TOTVS Ne - Anderson
  @history
    12/05/2023 - Desenvolvimento da Rotina.
/*/
// -----------------------------------------------------------
User Function MT150ROT()
  aAdd(aRotina, {"Reenviar E-Mail - Fornecedor","U_ACOMW056(3,Nil,SC8->C8_NUM)",0,1,0,.F.})
Return aRotina
