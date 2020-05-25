import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dart_code_metrics/src/models/code_issue.dart';
import 'package:dart_code_metrics/src/models/code_issue_severity.dart';

import 'base_rule.dart';
import 'rule_utils.dart';

// Inspired by TSLint (https://palantir.github.io/tslint/rules/no-boolean-literal-compare/)

class NoBooleanLiteralCompareRule extends BaseRule {
  static const _failure =
      'Comparing boolean values to boolean literals is unnecessary, as those expressions will result in booleans too. Just use the boolean values directly or negate them.';

  static const _useItDirectly =
      'This expression is unnecessarily compared to a boolean. Just use it directly.';
  static const _negate =
      'This expression is unnecessarily compared to a boolean. Just negate it.';

  const NoBooleanLiteralCompareRule()
      : super(
          id: 'no-boolean-literal-compare',
          severity: CodeIssueSeverity.style,
        );

  @override
  Iterable<CodeIssue> check(CompilationUnit unit, Uri sourceUrl) {
    final _visitor = _Visitor();

    unit.visitChildren(_visitor);

    final issues = <CodeIssue>[];

    for (final expression in _visitor.expressions) {
      final leftOperandBooleanLiteral =
          expression.leftOperand is BooleanLiteral;

      final booleanLiteralOperand = (leftOperandBooleanLiteral
              ? expression.leftOperand
              : expression.rightOperand)
          .toString();

      final correction = (leftOperandBooleanLiteral
              ? expression.rightOperand
              : expression.leftOperand)
          .toString();

      final useDirect = (expression.operator.type == TokenType.EQ_EQ &&
              booleanLiteralOperand == 'true') ||
          (expression.operator.type == TokenType.BANG_EQ &&
              booleanLiteralOperand == 'false');

      issues.add(createIssue(
          this,
          _failure,
          expression.toString(),
          useDirect ? correction : '!$correction',
          useDirect ? _useItDirectly : _negate,
          sourceUrl,
          unit.lineInfo,
          expression.offset));
    }

    return issues;
  }
}

class _Visitor extends RecursiveAstVisitor<Object> {
  static const _scannedTokenTypes = [TokenType.EQ_EQ, TokenType.BANG_EQ];

  final _expressions = <BinaryExpression>[];

  Iterable<BinaryExpression> get expressions => _expressions;

  @override
  void visitBinaryExpression(BinaryExpression node) {
    super.visitBinaryExpression(node);

    if (_scannedTokenTypes.any((element) => element == node.operator.type) &&
        (node.leftOperand is BooleanLiteral ||
            node.rightOperand is BooleanLiteral)) {
      _expressions.add(node);
    }
  }
}