import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'game_model.dart';
import 'letter_cell.dart';

class GridBoard extends StatefulWidget {
  const GridBoard({super.key});

  @override
  State<GridBoard> createState() => _GridBoardState();
}

class _GridBoardState extends State<GridBoard> {
  final GlobalKey _gridKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
      builder: (context, game, child) {
        return GestureDetector(
          onPanStart: (details) => _handleInput(context, details.localPosition),
          onPanUpdate: (details) => _handleInput(context, details.localPosition),
          onPanEnd: (_) => game.endDrag(),
          child: Container(
            key: _gridKey,
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                // The Grid of letters
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: game.columns,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: game.grid.length,
                    itemBuilder: (context, index) {
                    bool isSelected = game.selectedIndices.contains(index);
                    bool isFound = game.foundIndices.contains(index);
                    // Determine if it's the spangram by checking if the found word it belongs to is spangram
                    // This is a bit expensive to check every frame if not optimized, but OK for 48 items.
                    // A better way is to store "foundSpangramIndices" in model.
                    // For now, let's assume if it is found, we check the color logic in paint or here.
                    // Simplified: just pass isFound. The LetterCell colors it blue.
                    // Wait, spangram needs yellow.
                    // Let's check model for spangram indices logic later. 
                    // For now, default blue.
                    
                    // Hint logic
                    bool isHinted = game.hintedIndices != null && game.hintedIndices!.contains(index);
                    
                    // Animation logic
                    int animationOrder = -1;
                    if (game.lastFoundWordIndices.contains(index)) {
                      animationOrder = game.lastFoundWordIndices.indexOf(index);
                    }
                    int animationTotalLength = game.lastFoundWordIndices.length;
                    
                    return LetterCell(
                      char: game.grid[index],
                      isSelected: isSelected,
                      isFound: isFound,
                      isSpangram: game.foundWords.contains(game.spangram) && (game.solutions[game.spangram]?.contains(index) ?? false),
                      isHinted: isHinted,
                      animationOrder: animationOrder,
                      animationTotalLength: animationTotalLength,
                    );
                  },
                ),
              ),
                // The selection line
                if (game.selectedIndices.isNotEmpty)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SelectionPainter(
                        selectedIndices: game.selectedIndices.toList(),
                        columnCount: game.columns,
                        gridKey: _gridKey,
                      ),
                    ),
                  ),
                // The found lines (permanent)
                // We should probably draw these behind the letters or overlay?
                // Strands style: The letters turn colored, and there is a line connecting them.
                // So we need a painter for found words too.
                Positioned.fill(
                  child: CustomPaint(
                    painter: _FoundWordsPainter(
                      foundWordsIndices: game.foundWords.map((w) => game.solutions[w]!).toList(),
                      spangramIndices: game.solutions[game.spangram] ?? [],
                      columnCount: game.columns,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleInput(BuildContext context, Offset localPosition) {
    final game = Provider.of<GameModel>(context, listen: false);
    
    final RenderBox? box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    final size = box.size;
    double width = size.width;
    // Padding is 16 all around.
    // Inner width = width - 32
    double innerWidth = width - 32;
    
    // 6 columns. 5 gaps of 8.0.
    // cellWidth * 6 + 8 * 5 = innerWidth
    // cellWidth = (innerWidth - 40) / 6
    double gap = 8.0;
    double cellWidth = (innerWidth - (gap * (game.columns - 1))) / game.columns;
    
    // GridView default aspect ratio is 1.0, so cellHeight = cellWidth
    double cellHeight = cellWidth;
    
    // Adjust localPosition to be relative to the grid content (remove padding)
    double x = localPosition.dx - 16;
    double y = localPosition.dy - 16;
    
    // Check bounds
    double totalHeight = (cellHeight * game.rows) + (gap * (game.rows - 1));
    // Remove strict bounds check to allow dragging slightly outside
    // if (x < 0 || x > innerWidth || y < 0 || y > totalHeight) return;
    
    // Hit test with radius
    // We iterate or find closest?
    // Finding closest is efficient.
    
    int col = ((x - cellWidth / 2) / (cellWidth + gap)).round();
    int row = ((y - cellHeight / 2) / (cellHeight + gap)).round();
    
    // Clamp
    if (col < 0) col = 0;
    if (col >= game.columns) col = game.columns - 1;
    if (row < 0) row = 0;
    if (row >= game.rows) row = game.rows - 1;
    
    // Calculate center of this candidate cell
    double cx = (col * (cellWidth + gap)) + cellWidth / 2;
    double cy = (row * (cellHeight + gap)) + cellHeight / 2;
    
    // Check distance
    double dx = x - cx;
    double dy = y - cy;
    double distSq = dx*dx + dy*dy;
    
    // Threshold: sensitivity. 
    // Cell width is roughly 50-60px.
    // If we want a gap between cells to avoid "elbows" in diagonals:
    // Radius should be less than (cellHeight/2) but large enough to be easy to hit.
    // Let's use 45% of cellWidth.
    // (0.45 * cellWidth)^2
    double radius = cellWidth * 0.40; // 40% leaves substantial gaps for diagonals
    if (distSq < radius * radius) {
      // We are in the hot zone
       int index = row * game.columns + col;
      if (index >= 0 && index < game.grid.length) {
        if (game.selectedIndices.isEmpty) {
          game.startDrag(index);
        } else {
          game.updateDrag(index);
        }
      }
    }
  }
} // End of State class

// ... (SelectionPainter, FoundWordsPainter remain)


class _SelectionPainter extends CustomPainter {
  final List<int> selectedIndices;
  final int columnCount;
  final GlobalKey gridKey;

  _SelectionPainter({required this.selectedIndices, required this.columnCount, required this.gridKey});

  @override
  void paint(Canvas canvas, Size size) {
    if (selectedIndices.isEmpty) return;

    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.5)
      ..strokeWidth = 24  // Thicker line
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    Path path = Path();
    
    // Geometry sync:
    // This painter is inside the Stack, which is inside the padding.
    // So 'size' IS the inner size.
    double innerWidth = size.width; 
    double gap = 8.0;
    double cellWidth = (innerWidth - (gap * (columnCount - 1))) / columnCount;
    double cellHeight = cellWidth;

    for (int i = 0; i < selectedIndices.length; i++) {
      int index = selectedIndices[i];
      int r = index ~/ columnCount;
      int c = index % columnCount;
      
      // Calculate center of cell relative to (0,0) of this painter
      double cx = (c * (cellWidth + gap)) + cellWidth / 2;
      double cy = (r * (cellHeight + gap)) + cellHeight / 2;
      
      if (i == 0) {
        path.moveTo(cx, cy);
      } else {
        path.lineTo(cx, cy);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _FoundWordsPainter extends CustomPainter {
   final List<List<int>> foundWordsIndices;
   final List<int> spangramIndices;
   final int columnCount;
   
   _FoundWordsPainter({
     required this.foundWordsIndices, 
     required this.spangramIndices, 
     required this.columnCount
   });

   @override
   void paint(Canvas canvas, Size size) {
    if (foundWordsIndices.isEmpty) return;

    double innerWidth = size.width; 
    double gap = 8.0;
    double cellWidth = (innerWidth - (gap * (columnCount - 1))) / columnCount;
    double cellHeight = cellWidth;

    for (var indices in foundWordsIndices) {
      if (indices.isEmpty) continue;
      
      bool isSpangram = _areListsEqual(indices, spangramIndices);

      final paint = Paint()
        ..color = isSpangram ? Colors.amber[400]!.withOpacity(0.5) : Colors.blue[300]!.withOpacity(0.4)
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      Path path = Path();
      for (int i = 0; i < indices.length; i++) {
        int index = indices[i];
        int r = index ~/ columnCount;
        int c = index % columnCount;
        
        double cx = (c * (cellWidth + gap)) + cellWidth / 2;
        double cy = (r * (cellHeight + gap)) + cellHeight / 2;
        
        if (i == 0) {
          path.moveTo(cx, cy);
        } else {
          path.lineTo(cx, cy);
        }
      }
      canvas.drawPath(path, paint);
    }
   }
   
   bool _areListsEqual(List<int> list1, List<int> list2) {
      if (list1.length != list2.length) return false;
      for (int i = 0; i < list1.length; i++) {
        if (list1[i] != list2[i]) return false;
      }
      return true;
   }

   @override
   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
