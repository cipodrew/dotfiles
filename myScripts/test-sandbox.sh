#!/bin/bash
# test-sandbox.sh

echo "=== Testing Bubblewrap Sandbox ==="
echo

# Test 1: Can we access current directory?
echo "1. Testing read/write in PWD:"
./sandbox.sh bash -c "
  touch test-file.txt
  [[ -f test-file.txt ]] && echo '  ✓ Can create files in PWD' || echo '  ✗ FAILED: Cannot create files in PWD'
  
  echo 'test content' > test-file.txt
  [[ -s test-file.txt ]] && echo '  ✓ Can write to pwd files' || echo '  ✗ FAILED: Cannot write to files'
  
  grep -q 'test content' test-file.txt && echo '  ✓ Can read pwd files' || echo '  ✗ FAILED: Cannot read files'
  
  rm test-file.txt
  [[ ! -f test-file.txt ]] && echo '  ✓ Can delete pwd files' || echo '  ✗ FAILED: Cannot delete files'
"
echo

# Test 2: Can we access home directory? (should fail)
echo "2. Testing home directory protection:"
./sandbox.sh bash -c "
  ls ~/Downloads 2>&1 | grep -q 'Permission denied\|cannot access' && echo '  ✓ Home directory blocked' || echo '  ✗ FAILED: Can access home'
  
  touch ~/test-sandbox-file.txt 2>/dev/null
  sleep 0.1
"
[[ -f ~/test-sandbox-file.txt ]] && echo '  ✗ FAILED: Can write to home (file exists!)' || echo '  ✓ Cannot write to home'
echo

# Test 3: Can we access SSH keys? (should fail)
echo "3. Testing sensitive file protection:"
./sandbox.sh bash -c "
  cat ~/.ssh/wsl_id_ed25519.pub 2>&1 | grep -q 'Permission denied\|No such file\|cannot access' && echo '  ✓ SSH keys protected' || echo '  ✗ FAILED: Can read SSH keys'
  ls ~/.ssh 2>&1 | grep -q 'Permission denied\|No such file\|cannot access' && echo '  ✓ .ssh directory protected' || echo '  ✗ FAILED: Can access .ssh'
"
echo

# Test 4: Can we access .gitconfig? (should work)
echo "4. Testing allowed config files:"
if [[ -f ~/.gitconfig ]]; then
  ./sandbox.sh bash -c "
    cat ~/.gitconfig > /dev/null 2>&1 && echo '  ✓ Can read .gitconfig' || echo '  ✗ FAILED: Cannot read .gitconfig'
    
    # Try to append and check if it actually happened
    ORIGINAL_SIZE=\$(wc -c < ~/.gitconfig 2>/dev/null || echo 0)
    echo '# test-line-sandbox' >> ~/.gitconfig 2>/dev/null
    sleep 0.1
  "
  # Check from host if file was modified
  grep -q '# test-line-sandbox' ~/.gitconfig && echo '  ✗ FAILED: .gitconfig is writable!' || echo '  ✓ .gitconfig is read-only'
else
  echo "  ⚠ No .gitconfig found to test"
fi
echo

# Test 5: Can we access binaries?
echo "5. Testing binary access:"
./sandbox.sh bash -c "
  which ls > /dev/null 2>&1 && echo '  ✓ Can access system binaries (ls)' || echo '  ✗ FAILED: Cannot access ls'
  which node > /dev/null 2>&1 && echo '  ✓ Can access node' || echo '  ⚠ Warning: node not found in PATH'
  which python3 > /dev/null 2>&1 && echo '  ✓ Can access python3' || echo '  ⚠ Warning: python3 not found'
"
echo

# Test 6: Can we access user binaries?
echo "6. Testing user binary directories:"
./sandbox.sh bash -c "
  [[ -d ~/.local/bin ]] && ls ~/.local/bin > /dev/null 2>&1 && echo '  ✓ Can access ~/.local/bin' || echo '  ⚠ ~/.local/bin not accessible or empty'
  [[ -d ~/.cargo/bin ]] && ls ~/.cargo/bin > /dev/null 2>&1 && echo '  ✓ Can access ~/.cargo/bin' || echo '  ⚠ ~/.cargo/bin not accessible or empty'
"
echo

# Test 7: Can we escape to parent directories?
echo "7. Testing directory traversal protection:"
PARENT_DIR=$(dirname "$PWD")
./sandbox.sh bash -c "
  cd .. 2>&1 && pwd
  touch ../test-escape-sandbox.txt 2>/dev/null
  sleep 0.1
"
[[ -f "$PARENT_DIR/test-escape-sandbox.txt" ]] && echo '  ✗ FAILED: Can write outside PWD (file exists in parent!)' || echo '  ✓ Cannot write outside PWD'
echo

# Test 8: Network access
echo "8. Testing network access:"
./sandbox.sh bash -c "
  ping -c1 -W1 8.8.8.8 > /dev/null 2>&1 && echo '  ✓ Network access available' || echo '  ✗ Network access blocked'
  curl -s --max-time 2 https://example.com > /dev/null 2>&1 && echo '  ✓ HTTPS access works' || echo '  ⚠ Cannot reach external sites'
"
echo

# Test 9: /tmp isolation
echo "9. Testing /tmp isolation:"
TEMP_TEST_FILE="/tmp/sandbox-test-$$-$RANDOM.txt"
./sandbox.sh bash -c "
  echo 'test' > '$TEMP_TEST_FILE'
  [[ -f '$TEMP_TEST_FILE' ]] && echo '  ✓ Can write to /tmp (inside sandbox)' || echo '  ✗ FAILED: Cannot write to /tmp'
  grep -q 'test' '$TEMP_TEST_FILE' && echo '  ✓ Can read from /tmp (inside sandbox)' || echo '  ✗ FAILED: Cannot read from /tmp'
"
# Check if we can see that file from outside (should not be visible on host)
sleep 0.1
[[ -f "$TEMP_TEST_FILE" ]] && echo '  ✗ FAILED: /tmp is not isolated (file visible on host!)' || echo '  ✓ /tmp is isolated from host'
echo

# Test 10: Can we see other directories?
echo "10. Testing other directory protection:"
./sandbox.sh bash -c "
  ls /root 2>&1 | grep -q 'Permission denied\|cannot access' && echo '  ✓ /root protected' || echo '  ⚠ Can access /root'
  ls /etc/shadow 2>&1 | grep -q 'Permission denied\|cannot access' && echo '  ✓ /etc/shadow protected' || echo '  ⚠ Can access /etc/shadow'
"
echo

# Test 11: Verify files written in PWD actually exist on host
echo "11. Testing PWD write persistence:"
TEST_FILE="test-persistence-$$-$RANDOM.txt"
./sandbox.sh bash -c "
  echo 'persistence test' > '$TEST_FILE'
  [[ -f '$TEST_FILE' ]] && echo '  ✓ File created in sandbox'
"
sleep 0.1
if [[ -f "$TEST_FILE" ]]; then
  if grep -q 'persistence test' "$TEST_FILE"; then
    echo '  ✓ File persists on host with correct content'
  else
    echo '  ✗ FAILED: File exists but content is wrong'
  fi
else
  echo '  ✗ FAILED: File does not persist to host'
fi
echo

echo "=== Test Complete ==="
