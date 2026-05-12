// lib/search_screen.dart
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:phantom_tunes/utilis/app_state.dart';
import 'package:phantom_tunes/screen_customization.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SongModel> _results = [];

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    final lower = query.toLowerCase();
    setState(() {
      _results = allSongs.value.where((song) {
        return song.title.toLowerCase().contains(lower) ||
            (song.artist ?? '').toLowerCase().contains(lower) ||
            (song.album ?? '').toLowerCase().contains(lower);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF0505),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 22),
          ),
        ),
        title: const Text(
          "SEARCH",
          style: TextStyle(
            fontFamily: 'Persona',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                border: Border.all(color: const Color(0xFFFF0505), width: 2),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                style: const TextStyle(
                  fontFamily: 'Arsenal',
                  color: Colors.white,
                  fontSize: 16,
                ),
                cursorColor: const Color(0xFFFF0505),
                decoration: InputDecoration(
                  hintText: "Search songs, artists, albums...",
                  hintStyle: TextStyle(
                    fontFamily: 'Arsenal',
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Image.asset(
                      "assets/icons/search.png",
                      height: 20,
                      color: const Color(0xFFFF0505),
                    ),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                          icon: const Icon(Icons.close, color: Colors.white54),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),

          // Results
          Expanded(
            child: _searchController.text.isEmpty
                ? _buildEmptyState()
                : _results.isEmpty
                    ? _buildNoResults()
                    : _buildResultsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/icons/search.png", height: 60, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            "Type to search your music",
            style: TextStyle(
              fontFamily: 'Arsenal',
              color: Colors.white.withValues(alpha: 0.3),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, color: Colors.white24, size: 60),
          const SizedBox(height: 16),
          Text(
            "No results for \"${_searchController.text}\"",
            style: const TextStyle(
              fontFamily: 'Arsenal',
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final song = _results[index];
        final realIndex = allSongs.value.indexOf(song);

        return CustomPaint(
          painter: BackgroundPainter(strokeColor: Colors.white, context: context),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 0.01 * MediaQuery.of(context).size.height,
            ),
            child: ListTile(
              leading: SizedBox(
                width: 48,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFF0505), width: 1.5),
                  ),
                  child: QueryArtworkWidget(
                    artworkBorder: BorderRadius.zero,
                    id: song.id,
                    type: ArtworkType.AUDIO,
                    nullArtworkWidget: Image.asset(
                      "assets/images/persona.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              title: Text(
                song.title,
                style: const TextStyle(
                  fontFamily: 'Arsenal',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: Text(
                "${song.artist ?? '<Unknown>'} • ${song.album ?? ''}",
                style: const TextStyle(
                  fontFamily: 'Arsenal',
                  color: Colors.white54,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              onTap: () async {
                if (realIndex >= 0) {
                  await audioHandler.playSongAt(realIndex);
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
