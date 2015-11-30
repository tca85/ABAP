/*----------------------------------------------------------------------*/
/*                  Aché Laboratórios Farmacêuticos                     */
/*----------------------------------------------------------------------*/
/* BSP      : YAPO - Apontamento de horas de ordens de processo - COR6N */
/* Módulo   : APO/PP                                                    */
/* ABAP     : Thiago Cordeiro Alves (ACTHIAGO)                          */
/* Descrição: Associa as funções JavaScript aos componentes HTMLs, e    */
/*            após alguma ação na tela, envia a requisição Ajax para o  */
/*            SAP através do método DO_HANDLE_EVENT() da classe         */
/*            YCL_CONTROLLER_APONTAMENTO_OP. O resultado é retornado em */
/*            em uma mensagem de sucesso/erro em Json, e em alguns casos*/
/*            retorna o conteúdo html de uma view                       */
/*----------------------------------------------------------------------*/

/*----------------------------------------------------------------------*/
/* Variáveis e constantes                                               */
/*----------------------------------------------------------------------*/
var odataTable                                    ;
var oLinhaSelecionada = ""                        ;
var requisicao        = 'cor6n?onInputProcessing='; // controller + evento + acão

/*----------------------------------------------------------------------*/
/* Pesquisar ordem de processo                                          */
/* ---> cor6n?onInputProcessing=pesquisarOP                             */
/*----------------------------------------------------------------------*/
function pesquisarOrdemProcesso() {
  var qtdDigitos = $('#ipt_nro_op').val().length;

  if (qtdDigitos == 0) {
    exibirMensagemPopup('error', 'Informe o número da ordem de processo');
  }else{
    $.ajax({
      type: "post",
      url : requisicao + 'pesquisarOP',
      data: { nro_op: $('#ipt_nro_op').val() },

      beforeSend: function () {
        waitingDialog.show('Carregando detalhes da ordem de processo');
      },
      complete: function () {
        waitingDialog.hide();
      },
      success: function (retorno) {
        try {
          //Verifica se o retorno é uma mensagem de erro em Json
          var erro = JSON.parse(retorno);
          exibirMensagemPopup(erro.tipo, erro.msg);
          $('#ipt_nro_op').val('');
        } catch (err) {
          //Retorna o html da view Operações
          $('#ipt_nro_op').val('');
          $('#divPesquisarOP').addClass('linhaOculta');
          $('#divConteudoView').html(retorno);
          $('#divConteudoView').show();
          setDataTable('#tabelaApto');
        }
      },
      // Retorna mensagem de erro se houver alguma exception não tratada
      // na requisição feita ao SAP - YCL_CONTROLLER_APONTAMENTO_OP-DO_HANDLE_EVENT();
      error: function (xhr, textStatus, errorThrown) {
        try {
          exibirMensagemPopup("error", xhr.responseText);
        } catch (err) {
          exibirMensagemPopup("error", err.message);
        }
      }
    });
  }
}

/*----------------------------------------------------------------------*/
/* Salvar confirmação de apontamento da ordem de processo               */
/* ---> cor6n?onInputProcessing=salvarApontamento                       */
/*----------------------------------------------------------------------*/
function salvarConfirmacao() {
  $.ajax({
    type: "post"                         ,
    url: requisicao + 'salvarApontamento',
    dataType: "json"                     ,
    data: {
      nro_op        : $('#nro_op').val()        ,
      centro        : $('#centro').val()        ,
      operacao      : $('#operacao').val()      ,
      fase          : $('#fase').val()          ,
      recurso       : $('#recurso').val()       ,
      hr_apo_tp_prep: $('#hr_apo_tp_prep').val(),
      hr_apo_tp_maq : $('#hr_apo_tp_maq').val() ,
      hr_hh_tp_prep : $('#hr_hh_tp_prep').val() ,
      hr_hh_tp_maq  : $('#hr_hh_tp_maq').val()  ,
      refugo        : $('#refugo').val()        ,
      qtd_boa       : $('#qtd_boa').val()       ,
      tipo_apto     : $('#tipo_apto').val()
    },

    beforeSend: function () {
      waitingDialog.show('Aguarde enquanto o apontamento é salvo');
    },
    complete: function () {
      waitingDialog.hide();
    },
    // Retorna a mensagem de sucesso/erro da requisição, em formato Json
    success: function (retorno) {
      try {
        if (retorno.tipo == 'success') {
          $('#ipt_nro_op').val($('#nro_op').val());

          odataTable.row('.selected').remove().draw(false);

          $('#divModalApontamento').modal('hide');
          $('#ipt_nro_op').val($('#nro_op').val());
          pesquisarOrdemProcesso();
        }
        exibirMensagemPopup(retorno.tipo, retorno.msg);
      } catch (err) {
        exibirMensagemPopup("error", err.message);
      }
    },
    // Retorna mensagem de erro se houver alguma exception não tratada
    // na requisição feita ao SAP - YCL_CONTROLLER_APONTAMENTO_OP-DO_HANDLE_EVENT();
    error: function (xhr, textStatus, errorThrown) {
      try {
        exibirMensagemPopup("error", xhr.responseText);
      } catch (err) {
        exibirMensagemPopup("error", err.message);
      }
    }
  });
}

/*----------------------------------------------------------------------*/
/* Logout da aplicação                                                  */
/*----------------------------------------------------------------------*/
function logout_webpage() {
  var sair = confirm("Deseja sair do sistema?");
  if (sair == true) {
    document.execCommand("ClearAuthenticationCache");
    $('#divLogout').html(result);
    $('#divLogout').show();
  }
}

/*----------------------------------------------------------------------*/
/* Exibir mensagens de erros através do Dialog do Bootstrap             */
/*----------------------------------------------------------------------*/
function exibirMensagemErroPopup() {
  if ($('#msgErro').length == 0) {
    return;
  }
  if ($('#msgErro').val() != '') {
    exibirMensagemPopup("error", $('#msgErro').val());
    $('#msgErro').val('');
  }
}

/*----------------------------------------------------------------------*/
/* Exibir mensagem em formato Popup                                     */
/*----------------------------------------------------------------------*/
function exibirMensagemPopup(tipoMsg, msg) {
  toastr[tipoMsg](msg, "Apontamento de horas de OP de granéis").options = {
    "closeButton": true,
    "debug": false,
    "newestOnTop": false,
    "progressBar": true,
    "positionClass": "toast-top-full-width",
    "preventDuplicates": true,
    "onclick": null,
    "showDuration": "600",
    "hideDuration": "1000",
    "timeOut": "5000",
    "extendedTimeOut": "1000",
    "showEasing": "swing",
    "hideEasing": "linear",
    "showMethod": "fadeIn",
    "hideMethod": "fadeOut"
  }
};

/*----------------------------------------------------------------------*/
/* Carregar detalhe das folhas de tempos - transação COR6N              */
/* ---> cor6n?onInputProcessing=confirmacaoParcial / confirmacaoFinal   */
/*----------------------------------------------------------------------*/
function carregarDetalhesFolhaTempos(tipoConfirmacao){
  $.ajax({
    type: "post"                        ,
    url : requisicao + tipoConfirmacao  ,
    data: { nro_op: $('#nro_op').val() },

    success: function (retorno) {
      switch (tipoConfirmacao) {
      case 'confirmacaoParcial':
      case 'confirmacaoFinal':
        try {
          //Verifica se o retorno é uma mensagem de erro em Json
          var erro = JSON.parse(retorno);
          exibirMensagemPopup(erro.tipo, erro.msg);
          break;
        }catch (err) {
          //Retorno é o conteúdo HTML da View apontarConfirmacao
          $('#divModalApontamento').html(retorno);
          $('#divModalApontamento').modal();

          $('#btnSalvar').click(function(){
             salvarConfirmacao();
          });
          break;
        }
      }
    },

    error: function (xhr, textStatus, errorThrown) {
      try {
        exibirMensagemPopup("error", xhr.responseText);
      }catch (err) {
        exibirMensagemPopup("error", err.message);
      }
    }
  });
}

/*----------------------------------------------------------------------*/
/* Exibir popup para confirmar exclusão da fase da ordem                */
/*----------------------------------------------------------------------*/
function estornarApto(jsonLinhaSelecionada) {
  var nro_op      = $('#nro_op').val()              ;
  var operacao    = jsonLinhaSelecionada.operacao   ;
  var confirmacao = jsonLinhaSelecionada.confirmacao;

  bootbox.dialog({
    title: "Apontamento de horas de OP de granéis - " + nro_op,
    message: "Deseja estornar a confirmação " + confirmacao + " da operação " + operacao + "?",
    buttons: {
      danger: {
        label: "Sim",
        className: "btn-danger",
        callback: function () {
          $.ajax({
            type: "post",
            url: requisicao + "confirmarEstorno",
            dataType: "json",
            data: {
              nro_op     : $('#nro_op').val()              ,
              centro     : $('#centro').val()              ,
              operacao   : jsonLinhaSelecionada.operacao   ,
              fase       : jsonLinhaSelecionada.fase       ,
              confirmacao: jsonLinhaSelecionada.confirmacao,
              recurso    : jsonLinhaSelecionada.recurso
            },
            beforeSend: function () {
              waitingDialog.show('Aguarde enquanto o apontamento é estornado');
            },
            complete: function () {
              waitingDialog.hide();
            },
            success: function (retorno) {
              if (retorno.tipo == 'success') {
                odataTable.row('.selected').remove().draw(false);
                exibirView("viewOperacoes");
              }
              exibirMensagemPopup(retorno.tipo, retorno.msg);
            },
            error: function (xhr, textStatus, errorThrown) {
            }
          });
        }
      },
      success: {
        label: "Não",
        className: "btn-success"
      }
    }
  });
}

/*----------------------------------------------------------------------*/
/* Conteúdo da célula selecionada no DataTable                          */
/*----------------------------------------------------------------------*/
function conteudoCelula(elementoClicado, nomeClasse) {
  return $(elementoClicado).closest('tr').find('.' + nomeClasse).html();
}

/*----------------------------------------------------------------------*/
/* DataTable do Bootstrap                                               */
/*----------------------------------------------------------------------*/
function setDataTable(nomeTabela) {
    odataTable = $(nomeTabela).DataTable({
    //Ordenação da 1a coluna
    "aaSorting": [0],
    language: {
      "sEmptyTable": "Nenhum registro encontrado",
      "sInfo": "Mostrando de _START_ até _END_ de _TOTAL_ registros",
      "sInfoEmpty": "Mostrando 0 até 0 de 0 registros",
      "sInfoFiltered": "(Filtrados de _MAX_ registros)",
      "sInfoPostFix": "",
      "sInfoThousands": ".",
      "sLengthMenu": "_MENU_ resultados por página",
      "sLoadingRecords": "Carregando...",
      "sProcessing": "Processando...",
      "sZeroRecords": "Nenhum registro encontrado",
      "sSearch": "Pesquisar",
      "oPaginate": {
        "sNext": "Próximo",
        "sPrevious": "Anterior",
        "sFirst": "Primeiro",
        "sLast": "Último"
      },
      "oAria": {
        "sSortAscending": ": Ordenar colunas de forma ascendente",
        "sSortDescending": ": Ordenar colunas de forma descendente"
      }
    }
  });

    $(nomeTabela + ' tbody').on('click', 'tr', function () {

      if ($(this).hasClass('selected')) {
        $(this).removeClass('selected');
        oLinhaSelecionada = "";

      } else {
        odataTable.$('tr.selected').removeClass('selected');
        $(this).addClass('selected');

        var json_linha  = '{ ';
            json_linha += '"operacao":'    + '"' + conteudoCelula(this, 'operacao'    ) + '",';
            json_linha += '"fase":'        + '"' + conteudoCelula(this, 'fase'        ) + '",';
            json_linha += '"recurso":'     + '"' + conteudoCelula(this, 'recurso'     ) + '",';
            json_linha += '"confirmacao":' + '"' + conteudoCelula(this, 'confirmacao' ) + '"' ;
            json_linha += '}';

        oLinhaSelecionada = jQuery.parseJSON(json_linha);
      }
  });

  odataTable.$('.estornar').click(function () {
    confirmarEstorno($(this));
  });

  $('#btnAptoParcial').click(function () {
    carregarDetalhesFolhaTempos('confirmacaoParcial');
  });

  $('#btnAptoFinal').click(function () {
    carregarDetalhesFolhaTempos('confirmacaoFinal');
  });

  $('#btnEstornarApto').click(function () {
    if (oLinhaSelecionada != ""){
      estornarApto(oLinhaSelecionada);
    } else {
      exibirMensagemPopup("error", 'Selecione uma confirmação para estornar');
    }
  });
}

/*----------------------------------------------------------------------*/
/* Inicialização                                                        */
/*----------------------------------------------------------------------*/
$(document).ready(function () {
  // Insere a máscara para os inputTexts abaixo:
  $('#ipt_nro_op'    ).mask('000000000000'     ,{reverse: false});
  $('#hr_apo_tp_prep').mask('0000000000000,000',{reverse: true });
  $('#hr_apo_tp_maq' ).mask('0000000000000,000',{reverse: true });
  $('#hr_hh_tp_prep' ).mask('0000000000000,000',{reverse: true });
  $('#hr_hh_tp_maq'  ).mask('0000000000000,000',{reverse: true });
  $('#qtd_boa'       ).mask('0000000000000,000',{reverse: true });
  $('#refugo'        ).mask('0000000000000,000',{reverse: true });

  // Configura a ação quando pressiona a tecla Enter
  $('#ipt_nro_op').keypress(function(event){
      var keycode = (event.keyCode ? event.keyCode : event.which);

      if(keycode == '13'){
        pesquisarOrdemProcesso();
      }
      event.stopPropagation();
  });

  // Associa o id do botão PesquisarOP com a função JavaScript
  $('#btnPesquisarOP').click(function(){
     pesquisarOrdemProcesso();
  });

  // Limpa o conteúdo html da view, e volta a exibir somente o botão de pesquisar
  $('#imgLogoAche').click(function(){
      $('#divConteudoView').empty();
      $('#divPesquisarOP').removeClass('linhaOculta');
      $('#ipt_nro_op').focus();
   });

});