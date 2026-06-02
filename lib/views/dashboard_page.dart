import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chamado_provider.dart';
import '../providers/theme_provider.dart'; // Importação do Tema
import '../models/chamado_model.dart';
import 'cadastro_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _filtroAtual = 'Todos'; 

  String _formatarDataHora(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} às ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  IconData _getIconeCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'trânsito': return Icons.traffic;
      case 'iluminação': return Icons.lightbulb;
      case 'saneamento': return Icons.water_drop;
      case 'segurança': return Icons.local_police;
      case 'limpeza urbana': return Icons.delete;
      case 'desastre natural': return Icons.storm;
      default: return Icons.report_problem;
    }
  }

  Color _getCorChamado(Chamado chamado) {
    if (chamado.status == 'Concluído') {
      return Colors.green;
    } else if (chamado.prioridade == 'Crítica') {
      return Colors.red;
    } else if (chamado.status == 'Em andamento') {
      return Colors.blue;
    } else if (chamado.status == 'Aberto') {
      return Colors.orange;
    }
    return Colors.grey;
  }

  // --- Função que constrói o Menu Lateral ---
  Widget _buildDrawer(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.location_city, color: Colors.white, size: 48),
                SizedBox(height: 8),
                Text('SOS Cidade', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                Text('Configurações', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text('Modo Escuro (Dark Mode)'),
            secondary: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Cidade'),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context), // O botão sanduíche aparece automaticamente aqui!
      body: Consumer<ChamadoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final total = provider.chamados.length;
          final abertos = provider.chamados.where((c) => c.status == 'Aberto').length;
          final andamento = provider.chamados.where((c) => c.status == 'Em andamento').length;
          final concluidos = provider.chamados.where((c) => c.status == 'Concluído').length;
          final criticos = provider.chamados.where((c) => c.prioridade == 'Crítica' && c.status != 'Concluído').length;

          List<Chamado> chamadosFiltrados = provider.chamados;
          if (_filtroAtual == 'Crítica') {
            chamadosFiltrados = chamadosFiltrados.where((c) => c.prioridade == 'Crítica' && c.status != 'Concluído').toList();
          } else if (_filtroAtual != 'Todos') {
            chamadosFiltrados = chamadosFiltrados.where((c) => c.status == _filtroAtual).toList();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadChamados();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.blue.withOpacity(0.1),
                  child: Column(
                    children: [
                      Text(
                        'Atualizado em: ${_formatarDataHora(DateTime.now())}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text('Total de chamados registrados: $total'),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCard('Abertos', abertos, Colors.orange, 'Aberto', Icons.folder_open, context),
                      _buildCard('Em Andamento', andamento, Colors.blue, 'Em andamento', Icons.autorenew, context),
                      _buildCard('Concluídos', concluidos, Colors.green, 'Concluído', Icons.check_circle, context),
                      _buildCard('Críticos', criticos, Colors.red, 'Crítica', Icons.warning, context),
                    ],
                  ),
                ),

                if (_filtroAtual != 'Todos')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Filtrando por: ${_filtroAtual.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => setState(() => _filtroAtual = 'Todos'),
                          child: const Text('Limpar Filtro'),
                        )
                      ],
                    ),
                  ),

                if (provider.hasCriticalAlert)
                  Container(
                    color: Colors.redAccent,
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'ALERTA: Mais de 5 chamados críticos ativos!',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),

                const Divider(),

                Expanded(
                  child: chamadosFiltrados.isEmpty
                      ? const Center(child: Text('Nenhum chamado encontrado para este filtro.'))
                      : ListView.builder(
                          itemCount: chamadosFiltrados.length,
                          itemBuilder: (context, index) {
                            final chamado = chamadosFiltrados[index];
                            final corBalao = _getCorChamado(chamado); 
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: corBalao.withOpacity(0.2), 
                                  child: Icon(
                                    _getIconeCategoria(chamado.categoria),
                                    color: corBalao,
                                  ),
                                ),
                                title: Text(chamado.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${chamado.categoria} • ${chamado.bairro}'),
                                    Text(chamado.tempoDecorrido, style: const TextStyle(color: Colors.blueGrey, fontSize: 12)),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(chamado.prioridade, style: TextStyle(
                                      color: chamado.prioridade == 'Crítica' ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    )),
                                    const SizedBox(height: 4),
                                    Text(chamado.status, style: TextStyle(
                                      fontSize: 12, 
                                      color: chamado.status == 'Concluído' ? Colors.green : Theme.of(context).textTheme.bodySmall?.color,
                                      fontWeight: chamado.status == 'Concluído' ? FontWeight.bold : FontWeight.normal
                                    )),
                                  ],
                                ),
                                onTap: () {
                                  if (chamado.status == 'Concluído') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Chamados concluídos não podem ser editados.'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CadastroPage(chamadoParaEditar: chamado),
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CadastroPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // Recebe o context agora para adaptar a cor do card conforme o tema
  Widget _buildCard(String titulo, int valor, Color cor, String filtroReferencia, IconData icone, BuildContext context) {
    bool isSelected = _filtroAtual == filtroReferencia;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filtroAtual = isSelected ? 'Todos' : filtroReferencia;
          });
        },
        child: Card(
          elevation: isSelected ? 4 : 1, 
          // Ajusta a cor de fundo dinamicamente se não estiver selecionado
          color: isSelected ? cor.withOpacity(0.15) : Theme.of(context).cardColor, 
          shape: RoundedRectangleBorder(
            side: BorderSide(color: isSelected ? cor : Colors.transparent, width: 2), 
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
            child: Column(
              children: [
                Icon(icone, color: cor, size: 20),
                const SizedBox(height: 4),
                Text(valor.toString(), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cor)),
                Text(titulo, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}