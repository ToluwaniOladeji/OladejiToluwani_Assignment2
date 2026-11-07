import 'package:campus_incident_app/models/enums.dart';
import 'package:campus_incident_app/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ALU email validation', () {
    test('accepts ALU addresses (case/space insensitive)', () {
      expect(Validators.isAluEmail('jane@alustudent.com'), isTrue);
      expect(Validators.isAluEmail('  Staff@AluEducation.com '), isTrue);
    });
    test('rejects other domains', () {
      expect(Validators.isAluEmail('jane@gmail.com'), isFalse);
      expect(Validators.isAluEmail('jane@alustudent.com.evil.io'), isFalse);
    });
    test('form validator messages', () {
      expect(Validators.aluEmail(''), 'Email is required');
      expect(Validators.aluEmail('nope'), 'Enter a valid email address');
      expect(Validators.aluEmail('a@gmail.com'), 'Use your ALU email address');
      expect(Validators.aluEmail('a@alustudent.com'), isNull);
    });
  });

  group('other validators', () {
    test('password needs 8+ chars', () {
      expect(Validators.password('short'), isNotNull);
      expect(Validators.password('longenough'), isNull);
    });
    test('required with minimum length', () {
      expect(Validators.required('  ', 'Title'), 'Title is required');
      expect(Validators.required('abc', 'Title', min: 4), isNotNull);
      expect(Validators.required('abcd', 'Title', min: 4), isNull);
    });
  });

  group('enums', () {
    test('status round-trips through its stored value', () {
      for (final s in IncidentStatus.values) {
        expect(IncidentStatus.fromValue(s.value), s);
      }
      expect(IncidentStatus.fromValue('garbage'), IncidentStatus.submitted);
    });
    test('category falls back safely', () {
      expect(IncidentCategory.fromName('water'), IncidentCategory.water);
      expect(IncidentCategory.fromName(null), IncidentCategory.facilities);
    });
  });
}