import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chamado_model.dart';
import '../providers/chamado_provider.dart';

class CadastroPage extends StatefulWidget {
  final Chamado? chamadoParaEditar; 

  const CadastroPage({Key? key, this.chamadoParaEditar}) : super(key: key);

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _responsavelController = TextEditingController();

  // Listas atualizadas com a primeira letra maiúscula
  final List<String> _categorias = ['Trânsito', 'Iluminação', 'Saneamento', 'Segurança', 'Limpeza urbana', 'Desastre natural'];
  final List<String> _prioridades = ['Baixa', 'Média', 'Alta', 'Crítica'];
  final List<String> _statusOpcoes = ['Aberto', 'Em andamento', 'Concluído'];

  String? _categoriaSelecionada;
  String? _prioridadeSelecionada;
  String _statusSelecionado = 'Aberto'; // Status padrão atualizado

  bool get _isEdicao => widget.chamadoParaEditar != null;

  @override
  void initState() {
    super.initState();
    if (_isEdicao) {
      final c = widget.chamadoParaEditar!;
      _tituloController.text = c.titulo;
      _descricaoController.text = c.descricao;
      _bairroController.text = c.bairro;
      _responsavelController.text = c.responsavel;
      _categoriaSelecionada = c.categoria;
      _prioridadeSelecionada = c.prioridade;
      _statusSelecionado = c.status;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _bairroController.dispose();
    _responsavelController.dispose();
    super.dispose();
  }

  void _salvarChamado() {
    if (_formKey.currentState!.validate()) {
      final chamado = Chamado(
        id: _isEdicao ? widget.chamadoParaEditar!.id : null,
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        categoria: _categoriaSelecionada!,
        prioridade: _prioridadeSelecionada!,
        bairro: _bairroController.text.trim(),
        responsavel: _responsavelController.text.trim(),
        data: _isEdicao ? widget.chamadoParaEditar!.data : DateTime.now(),
        status: _statusSelecionado,
      );

      final provider = Provider.of<ChamadoProvider>(context, listen: false);

      Future acaoSalvar = _isEdicao 
          ? provider.updateChamado(chamado) 
          : provider.addChamado(chamado);

      acaoSalvar.then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString(), style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdicao ? 'Editar Chamado' : 'Registrar Chamado'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? 'O título é obrigatório' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(labelText: 'Descrição', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => value == null || value.trim().isEmpty ? 'A descrição é obrigatória' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
                value: _categoriaSelecionada,
                items: _categorias.map((String categoria) => DropdownMenuItem(value: categoria, child: Text(categoria))).toList(),
                onChanged: (val) => setState(() => _categoriaSelecionada = val),
                validator: (value) => value == null ? 'Selecione uma categoria' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Prioridade', border: OutlineInputBorder()),
                value: _prioridadeSelecionada,
                items: _prioridades.map((String prioridade) => DropdownMenuItem(value: prioridade, child: Text(prioridade))).toList(),
                onChanged: (val) => setState(() => _prioridadeSelecionada = val),
                validator: (value) => value == null ? 'Selecione uma prioridade' : null,
              ),
              const SizedBox(height: 16),

              if (_isEdicao) ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Status do Chamado', border: OutlineInputBorder()),
                  value: _statusSelecionado,
                  items: _statusOpcoes.map((String status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                  onChanged: (val) => setState(() => _statusSelecionado = val!),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(labelText: 'Bairro', border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? 'O bairro é obrigatório' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _responsavelController,
                decoration: const InputDecoration(labelText: 'Responsável (Seu Nome)', border: OutlineInputBorder()),
                validator: (value) => value == null || value.trim().isEmpty ? 'O responsável é obrigatório' : null,
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _salvarChamado,
                child: Text(_isEdicao ? 'Atualizar Chamado' : 'Salvar Chamado', style: const TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}