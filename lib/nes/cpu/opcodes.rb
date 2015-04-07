module Opcodes
  OPCODE_LIST = {
    'LDA' => [
      [0xa9, 2, 2],
      [0xa5, 2, 3],
      [0xb5, 2, 4],
      [0xad, 3, 4],
      [0xbd, 3, 4],
      [0xb9, 3, 4],
      [0xa1, 2, 6],
      [0xb1, 2, 5]
    ]
  }
end
