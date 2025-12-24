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
                GridView.builder(
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
                    
                    return LetterCell(
                      char: game.grid[index],
                      isSelected: isSelected,
                      isFound: isFound,
                      isSpangram: game.foundWords.contains(game.spangram) && (game.solutions[game.spangram]?.contains(index) ?? false),
                    );
                  },
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
                      foundWordsIndices: game.foundWords.map((w) => game.solutions[w]!).toList(), // This is getting complex, maybe simplify
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
    
    // We need to map localPosition to an index.
    // This requires knowing the size of the gri and cells.
    // Since GridView is flexible, this is tricky without LayoutBuilder or RenderBox.
    
    // For MVVM simplicity:
    // We can assume equal sizing.
    final RenderBox? box = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    
    // Size of the container
    final size = box.size;
    
    // With padding 16.
    double width = size.width;
    double height = size.height;
    
    // Helper to find index from offset
    // 6 cols, 8 rows. Spacing 8.
    // Cell width approx = (width - (5 * 8)) / 6
    
    // Correct approach: HitTest?
    // Or just simple math if we know the geometry.
    // Let's do simple math assuming the touch is within bounds.
    
    // Subtract padding if strictly inside container with padding (16)
    // But localPosition is relative to the Container which has padding? 
    // Wait, the Container has padding 16, so the GridView is inside that.
    // But the gesture detector is on the Container.
    
    double x = localPosition.dx - 16;
    double y = localPosition.dy - 16;
    
    if (x < 0 || y < 0 || x > width - 16 || y > height - 16) return;
    
    // Approximate cell size
    // We can get the cell dimensions from the width
    double cellWidth = (width - 32) / game.columns; // 32 is total horizontal padding
    double cellHeight = (height - 32) / game.rows; // not exact if aspect ratio 1.0 enforced, GridView might have bottom gap.
    
    // Actually GridView default aspect ratio is 1.0.
    // So cellHeight == cellWidth.
    // We should use that.
    
    int col = (x / cellWidth).floor();
    int row = (y / cellWidth).floor(); // assuming square cells
    
    if (col >= 0 && col < game.columns && row >= 0 && row < game.rows) {
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
}

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
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Path path = Path();
    
    // We need to calculate center points of cells again.
    // Duplicated math from _handleInput - ideally shared.
    double cellWidth = (size.width - 32) / columnCount; // 32 for padding
    // Offset by padding (16)
    double offsetX = 16 + cellWidth / 2;
    double offsetY = 16 + cellWidth / 2;

    for (int i = 0; i < selectedIndices.length; i++) {
      int index = selectedIndices[i];
      int r = index ~/ columnCount;
      int c = index % columnCount;

      double x = (c * cellWidth) + offsetX; // This assumes spacing is handled inside cellWidth calculation conceptually or we need to account for gap?
      // GridView spacing is 8.
      // So (cellWidth * c) isn't enough.
      // Total width = (cellW * 6) + (space * 5)
      // cellW = (AvailableWidth - (space * 5)) / 6
      
      // Let's refine geometry.
      // 5 spaces of 8.0 = 40.0
      double availableWidth = size.width - 32;
      double actualCellWidth = (availableWidth - (8 * (columnCount - 1))) / columnCount;
      
      double cx = 16 + (c * (actualCellWidth + 8)) + actualCellWidth / 2;
      double cy = 16 + (r * (actualCellWidth + 8)) + actualCellWidth / 2; // Assuming square
      
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
   final int columnCount;
   
   _FoundWordsPainter({required this.foundWordsIndices, required this.columnCount});
   
   @override
  void paint(Canvas canvas, Size size) {
    // Similar logic but for found words, maybe different colors
    // For now simple blue lines
     final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
      
    // Geometry
    double availableWidth = size.width - 32;
    double actualCellWidth = (availableWidth - (8 * (columnCount - 1))) / columnCount;
      
    for (var indices in foundWordsIndices) {
      Path path = Path();
      for (int i = 0; i < indices.length; i++) {
        int index = indices[i];
        int r = index ~/ columnCount;
        int c = index % columnCount;
        
        double cx = 16 + (c * (actualCellWidth + 8)) + actualCellWidth / 2;
        double cy = 16 + (r * (actualCellWidth + 8)) + actualCellWidth / 2;
        
        if (i == 0) path.moveTo(cx, cy);
        else path.lineTo(cx, cy);
      }
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
