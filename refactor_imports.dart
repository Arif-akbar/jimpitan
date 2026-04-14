import 'dart:io';

void main() {
  final dir = Directory('D:/FOLDER-KULIAH/belajar koding/USAHAKU/jimpitan-digital/lib');
  final libPrefix = dir.path.replaceAll('\\', '/');
  
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      bool changed = false;
      final lines = file.readAsLinesSync();
      
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.startsWith('import ') && line.contains("C:/") || line.contains("C:\\")) {
            // Replace any absolute C: path imports, though we know there are none.
            lines[i] = line.replaceAll(RegExp(r"['""]C:.*?/lib/(.*?)['""]"), "'package:jimpitan_digital/\$1'");
            changed = true;
        }
        else if (line.startsWith('import ') && line.contains("import '../") || line.contains("import '../../")) {
            // It's a relative import. We want to convert it to a package: import.
            // Example line: import '../../core/constants/app_colors.dart';
            final match = RegExp(r"import ['""](.*?)['""];").firstMatch(line);
            if (match != null) {
                final relPath = match.group(1)!;
                if(relPath.startsWith('../')) {
                    // Resolve the relative path
                    final currentPath = file.parent.path.replaceAll('\\', '/');
                    // Remove lib prefix to get path inside lib
                    final relativeToLib = currentPath.substring(libPrefix.length + (currentPath.length > libPrefix.length ? 1 : 0));
                    
                    var parts = relativeToLib.isEmpty ? [] : relativeToLib.split('/');
                    var relParts = relPath.split('/');
                    
                    for (var part in relParts) {
                        if (part == '..') {
                            if (parts.isNotEmpty) parts.removeLast();
                        } else {
                            parts.add(part);
                        }
                    }
                    
                    final newPath = parts.join('/');
                    lines[i] = "import 'package:jimpitan_digital/$newPath';";
                    changed = true;
                }
            }
        }
      }
      
      if (changed) {
        file.writeAsStringSync(lines.join('\n') + '\n');
        print('Updated \${file.path}');
      }
    }
  }
}
