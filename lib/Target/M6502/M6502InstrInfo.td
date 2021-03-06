// TODO: header stuff

// Custom operand types

// XXX: this seems to be missing from Target.td
let OperandType = "OPERAND_IMMEDIATE" in {
  def iPTRimm : Operand<i16>;
}

let OperandNamespace = "M6502" in {

// TODO: M6502-specific operand types

} // OperandNamespace = "M6502"

// TODO: move into M6502 namespace
def brtarget : Operand<OtherVT>;

// Custom type profiles

def SDT_M6502Shift1 : SDTypeProfile<1, 1, [SDTCisVT<0, i8>, SDTCisVT<1, i8>]>;
def SDT_M6502AbsAddr : SDTypeProfile<1, 1, [SDTCisVT<0, OtherVT>,
                                            SDTCisVT<1, i16>]>;
def SDT_M6502AbsIndexAddr : SDTypeProfile<1, 2, [SDTCisVT<0, OtherVT>,
                                                 SDTCisVT<1, i16>,
                                                 SDTCisVT<2, i8>]>;
def SDT_M6502HiLoAddr : SDTypeProfile<1, 2, [SDTCisVT<0, OtherVT>,
                                             SDTCisVT<1, i8>,
                                             SDTCisVT<2, i8>]>;
def SDT_M6502HiLoIndexAddr : SDTypeProfile<1, 3, [SDTCisVT<0, OtherVT>,
                                                  SDTCisVT<1, i8>,
                                                  SDTCisVT<2, i8>,
                                                  SDTCisVT<3, i8>]>;
def SDT_M6502FIAddr : SDTypeProfile<1, 2, [SDTCisVT<0, OtherVT>,
                                           SDTCisVT<1, i16>,
                                           SDTCisVT<2, i16>]>;
def SDT_M6502FIIndexAddr : SDTypeProfile<1, 3, [SDTCisVT<0, OtherVT>,
                                                SDTCisVT<1, i16>,
                                                SDTCisVT<2, i16>,
                                                SDTCisVT<3, i8>]>;
def SDT_M6502AddrElement : SDTypeProfile<1, 1, [SDTCisVT<0, i8>,
                                                SDTCisVT<1, i16>]>;
def SDT_M6502LoadFrom : SDTypeProfile<1, 1,
                                     [SDTCisVT<0, i8>,
                                      SDTCisVT<1, OtherVT>]>;
def SDT_M6502StoreTo : SDTypeProfile<0, 2,
                                    [SDTCisVT<0, i8>,
                                     SDTCisVT<1, OtherVT>]>;
def SDT_M6502BrInd : SDTypeProfile<0, 1, [SDTCisVT<0, OtherVT>]>;

def SDT_M6502Call : SDTypeProfile<0, -1, [SDTCisVT<0, iPTR>]>;
def SDT_M6502Cmp : SDTypeProfile<0, 2, [SDTCisVT<0, i8>, SDTCisVT<1, i8>]>;
// BSet and BClear parameters: Flag, Branch Target
def SDT_M6502BSet : SDTypeProfile<0, 2,
                                  [SDTCisVT<0, OtherVT>, SDTCisVT<1, OtherVT>]>;
def SDT_M6502BClear : SDTypeProfile<0, 2,
                                    [SDTCisVT<0, OtherVT>, SDTCisVT<1, OtherVT>]>;
def SDT_M6502SelectCC : SDTypeProfile<1, 3, [SDTCisVT<0, i8>, SDTCisVT<1, i8>,
                                             SDTCisVT<2, i8>, SDTCisVT<3, i8>]>;
def SDT_M6502Flag : SDTypeProfile<1, 0, [SDTCisVT<0, OtherVT>]>;

// Custom nodes

// Shift 1 nodes
def M6502asl1 : SDNode<"M6502ISD::ASL1", SDT_M6502Shift1,
                       [SDNPOutGlue]>;
def M6502rol1 : SDNode<"M6502ISD::ROL1", SDT_M6502Shift1,
                       [SDNPOutGlue, SDNPInGlue]>;

// Address-related nodes
def M6502absaddr : SDNode<"M6502ISD::ABSADDR", SDT_M6502AbsAddr,
                          []>; // get absolute address
def M6502absindexaddr : SDNode<"M6502ISD::ABSINDEXADDR", SDT_M6502AbsIndexAddr,
                               []>; // get absolute address plus variable offset
def M6502hiloaddr : SDNode<"M6502ISD::HILOADDR", SDT_M6502HiLoAddr,
                           []>; // get address from Hi, Lo bytes
def M6502hiloindexaddr : SDNode<"M6502ISD::HILOINDEXADDR", SDT_M6502HiLoIndexAddr,
                                []>; // get address from Hi, Lo bytes plus variable offset
def M6502fiaddr : SDNode<"M6502ISD::FIADDR", SDT_M6502FIAddr,
                         []>; // get address of frameindex
def M6502fiindexaddr : SDNode<"M6502ISD::FIINDEXADDR", SDT_M6502FIIndexAddr,
                              []>; // get address of frameindex plus variable offset
def M6502addrhi : SDNode<"M6502ISD::ADDRHI", SDT_M6502AddrElement, []>;
                      // Hi element of absolute address
def M6502addrlo : SDNode<"M6502ISD::ADDRLO", SDT_M6502AddrElement, []>;
                      // Lo element of absolute address
def M6502fihi : SDNode<"M6502ISD::FIHI", SDT_M6502AddrElement, []>;
                      // Hi element of frameindex address
def M6502filo : SDNode<"M6502ISD::FILO", SDT_M6502AddrElement, []>;
                      // Lo element of frameindex address

 // Loading and storing-related nodes
 def M6502loadfrom : SDNode<"M6502ISD::LOADFROM", SDT_M6502LoadFrom,
                            [SDNPHasChain, SDNPMayLoad]>; // load from pointer
 def M6502storeto : SDNode<"M6502ISD::STORETO", SDT_M6502StoreTo,
                           [SDNPHasChain, SDNPMayStore]>; // store to pointer

// Indirect branch nodes
def M6502brind : SDNode<"M6502ISD::BRIND", SDT_M6502BrInd,
                        [SDNPHasChain]>;


// Call-related nodes
def M6502call : SDNode<"M6502ISD::CALL", SDT_M6502Call,
                       [SDNPHasChain, SDNPOutGlue, SDNPInGlue, SDNPVariadic]>;
def M6502return : SDNode<"M6502ISD::RETURN", SDTNone,
                         [SDNPHasChain, SDNPOptInGlue, SDNPVariadic]>;

// Comparison and conditional branching nodes
def M6502cmp : SDNode<"M6502ISD::CMP", SDT_M6502Cmp, [SDNPOutGlue]>;
def M6502bset : SDNode<"M6502ISD::BSET", SDT_M6502BSet,
                       [SDNPHasChain, SDNPInGlue, SDNPOutGlue]>;
def M6502bclear : SDNode<"M6502ISD::BCLEAR", SDT_M6502BClear,
                         [SDNPHasChain, SDNPInGlue, SDNPOutGlue]>;
def M6502selectcc : SDNode<"M6502ISD::SELECT_CC", SDT_M6502SelectCC,
                           [SDNPInGlue]>;

// Flag nodes for bset and bclear
def M6502nflag : SDNode<"M6502ISD::NFLAG", SDT_M6502Flag, []>; // negative
def M6502zflag : SDNode<"M6502ISD::ZFLAG", SDT_M6502Flag, []>; // zero
def M6502cflag : SDNode<"M6502ISD::CFLAG", SDT_M6502Flag, []>; // carry
def M6502vflag : SDNode<"M6502ISD::VFLAG", SDT_M6502Flag, []>; // overflow

// Instructions

class I : Instruction {
  let Namespace = "M6502";
  let isPseudo = 1; // XXX: for now, all instructions are pseudo-instructions.
}

// TODO: Add Defs and Uses for Flag registers in instructions that modify flags

multiclass AccOperatorI<string AsmName, SDPatternOperator Oper> {
  // Memory register operand (pseudo)
  def _mem : I {
    let OutOperandList = (outs Acc:$ao);
    let InOperandList = (ins Acc:$ai, MemReg:$m);
    let Constraints = "$ao = $ai";
    let AsmString = AsmName # "_mem $ai, $m";
    let Pattern = [(set Acc:$ao, (Oper Acc:$ai, MemReg:$m))];
  }

  // Immediate
  def _imm : I {
    let OutOperandList = (outs Acc:$ao);
    let InOperandList = (ins Acc:$ai, i8imm:$x);
    let Constraints = "$ao = $ai";
    let AsmString = AsmName # "_imm $ai, $x";
    let Pattern = [(set Acc:$ao, (Oper Acc:$ai, imm:$x))];
  }

  // Stack
  def _stack : I {
    let OutOperandList = (outs Acc:$ao);
    // FIXME: operands might break isCommutable rule?
    let isCommutable = 0;
    let InOperandList = (ins Acc:$ai, iPTRimm:$fi, iPTRimm:$offs);
    let Constraints = "$ao = $ai";
    let AsmString = AsmName # "_stack $ai, [$fi]+$offs";
    let Pattern = [(set Acc:$ao, (Oper Acc:$ai, (M6502loadfrom (M6502fiaddr tframeindex:$fi, timm:$offs))))];
    let mayLoad = 1;
  }

  // Absolute address
  def _abs : I {
    let OutOperandList = (outs Acc:$ao);
    // FIXME: operands might break isCommutable rule?
    let isCommutable = 0;
    let InOperandList = (ins Acc:$ai, iPTRimm:$addr);
    let Constraints = "$ao = $ai";
    let AsmString = AsmName # "_abs $ai, $addr";
    let Pattern = [(set Acc:$ao, (Oper Acc:$ai, (M6502loadfrom (M6502absaddr timm:$addr))))];
    let mayLoad = 1;
  }

  // Absolute-indexed address
  def _abs_index : I {
    let OutOperandList = (outs Acc:$ao);
    // FIXME: operands might break isCommutable rule?
    let isCommutable = 0;
    let InOperandList = (ins Acc:$ai, iPTRimm:$addr, Index:$i);
    let Constraints = "$ao = $ai";
    let AsmString = AsmName # "_abs_index $ai, $addr,$i";
    let Pattern = [(set Acc:$ao, (Oper Acc:$ai, (M6502loadfrom (M6502absindexaddr timm:$addr, Index:$i))))];
    let mayLoad = 1;
  }

  // Hi, Lo address
  def _hi_lo : I {
    let OutOperandList = (outs Acc:$ao);
    // FIXME: operands might break isCommutable rule?
    let isCommutable = 0; // FIXME: check whether this overrides isCommutable from defm.
    let InOperandList = (ins Acc:$ai, MHReg:$hi, MLReg:$lo);
    let Constraints = "$ao = $ai";
    let AsmString = AsmName # "_hi_lo $ai, ($hi, $lo)";
    let Pattern = [(set Acc:$ao, (Oper Acc:$ai, (M6502loadfrom (M6502hiloaddr MHReg:$hi, MLReg:$lo))))];
    let mayLoad = 1;
  }

  // TODO: stack plus index address
  // TODO: indirect address
  // TODO: indirect-indexed address
}

// XXX: Fake "AD0" instruction should generate:
//      CLC
//      ADC ...
let isCommutable = 1, Defs = [NF, ZF, CF, VF] in
  defm AD0 : AccOperatorI<"AD0", addc>;
let isCommutable = 1, Defs = [NF, ZF, CF, VF], Uses = [CF] in
  defm ADC : AccOperatorI<"ADC", adde>;

// XXX: Fake instruction for regular add
// TODO: delete
let isCommutable = 1, Defs = [NF, ZF, CF, VF] in
  defm ADD : AccOperatorI<"ADD", add>;

// XXX: Fake "SB1" instruction should generate:
//      SEC
//      SBC ...
let Defs = [NF, ZF, CF, VF] in
  defm SB1 : AccOperatorI<"SB1", subc>;
let Defs = [NF, ZF, CF, VF], Uses = [CF] in
  defm SBC : AccOperatorI<"SBC", sube>;

// XXX: Fake instruction for regular sub
// TODO: delete
let Defs = [NF, ZF, CF, VF] in
  defm SUB : AccOperatorI<"SUB", sub>;

let isCommutable = 1, Defs = [NF, ZF] in
  defm AND : AccOperatorI<"AND", and>;
let isCommutable = 1, Defs = [NF, ZF] in
  defm EOR : AccOperatorI<"EOR", xor>;
let isCommutable = 1, Defs = [NF, ZF] in
  defm ORA : AccOperatorI<"ORA", or>;

// Shift left by immediate amount
// FIXME: This is not a real instruction in 6502. The closest equivalent is
// ASL, which shifts A left by one bit.
def ASL_imm : I {
  let Defs = [NF, ZF, CF];
  let OutOperandList = (outs Acc:$ao);
  let InOperandList = (ins Acc:$ai, i8imm:$x);
  let Constraints = "$ao = $ai";
  let AsmString = "ASL_imm $ai, $x";
  let Pattern = [(set Acc:$ao, (shl Acc:$ai, (i8 imm:$x)))];
}

// Arithmetic shift right
// FIXME: This is not a real instruction in 6502. This instruction must be
// expanded to CMP's and ROR's. For example, see
// <https://wiki.nesdev.com/w/index.php/6502_assembly_optimisations#Arithmetic_shift_right>
def ASR_imm : I {
  let Defs = [NF, ZF, CF];
  let OutOperandList = (outs Acc:$ao);
  let InOperandList = (ins Acc:$ai, i8imm:$x);
  let Constraints = "$ao = $ai";
  let AsmString = "ASR_imm $ai, $x";
  let Pattern = [(set Acc:$ao, (sra Acc:$ai, (i8 imm:$x)))];
}

// Logical shift right
// FIXME: This is not a real instruction in 6502. The closest equivalent is
// LSR, which shifts A right by one bit.
def LSR_imm : I {
  let Defs = [ZF, CF];
  let OutOperandList = (outs Acc:$ao);
  let InOperandList = (ins Acc:$ai, i8imm:$x);
  let Constraints = "$ao = $ai";
  let AsmString = "LSR_imm $ai, $x";
  let Pattern = [(set Acc:$ao, (srl Acc:$ai, (i8 imm:$x)))];
}

// Shift left one bit, move highest bit to CF
// TODO: memory operands
def ASL_1 : I {
  let Defs = [NF, ZF, CF];
  let OutOperandList = (outs Acc:$ao);
  let InOperandList = (ins Acc:$ai);
  let Constraints = "$ao = $ai";
  let AsmString = "ASL $ai";
  let Pattern = [(set Acc:$ao, (M6502asl1 Acc:$ai))];
}

// Rotate left one bit through CF
// TODO: memory operands
def ROL_1 : I {
  let Defs = [NF, ZF, CF];
  let Uses = [CF];
  let OutOperandList = (outs Acc:$ao);
  let InOperandList = (ins Acc:$ai);
  let Constraints = "$ao = $ai";
  let AsmString = "ROL $ai";
  let Pattern = [(set Acc:$ao, (M6502rol1 Acc:$ai))];
}

// Branch on flag instructions
multiclass CondBranchI<SDPatternOperator Flag, string IfSetName,
                       string IfClearName> {
  def _set : I {
    let OutOperandList = (outs);
    let InOperandList = (ins brtarget:$target);
    let AsmString = IfSetName # " $target";
    let Pattern = [(M6502bset (Flag), bb:$target)];
    let isBranch = 1;
    let isTerminator = 1;
  }

  def _clear : I {
    let OutOperandList = (outs);
    let InOperandList = (ins brtarget:$target);
    let AsmString = IfClearName # " $target";
    let Pattern = [(M6502bclear (Flag), bb:$target)];
    let isBranch = 1;
    let isTerminator = 1;
  }
}

let Uses = [NF] in
  defm BN : CondBranchI<M6502nflag, "BMI", "BPL">;
let Uses = [ZF] in
  defm BZ : CondBranchI<M6502zflag, "BEQ", "BNE">;
let Uses = [CF] in
  defm BC : CondBranchI<M6502cflag, "BCS", "BCC">;
let Uses = [VF] in
  defm BV : CondBranchI<M6502vflag, "BVS", "BVC">;

let usesCustomInserter = 1 in {
  // NOTE: Custom inserter converts SELECT to conditional branches
  // TODO: add Flag node operand to select instructions
  // FIXME: restrict to physregs
  def SELECT : I {
    let OutOperandList = (outs General:$r);
    let InOperandList = (ins General:$a, General:$b, i8imm:$cc);
    let AsmString = "SELECT $a, $b, $cc # Pseudo";
    let Pattern = [(set General:$r, (M6502selectcc General:$a, General:$b,
                                                   imm:$cc))];
  }
}

// Compare Register with Immediate
// TODO: Define CMP with a multiclass like AccOperatorI
// NOTE: 6502 has CMP instructions for all registers (CMP, CPX, CPY). However,
// only the first one has indexed addressing modes.
def CMP_imm : I {
  let Defs = [NF, ZF, CF];
  let OutOperandList = (outs);
  let InOperandList = (ins PhysReg:$ai, i8imm:$x);
  let AsmString = "CMP_imm $ai, $x";
  let Pattern = [(M6502cmp PhysReg:$ai, imm:$x)];
}

// Compare Register with Memory
// TODO: Define CMP with a multiclass like AccOperatorI
def CMP_mem : I {
  let Defs = [NF, ZF, CF];
  let OutOperandList = (outs);
  let InOperandList = (ins PhysReg:$ai, MemReg:$x);
  let AsmString = "CMP_mem $ai, $x";
  let Pattern = [(M6502cmp PhysReg:$ai, MemReg:$x)];
}

// Jump
def JMP_abs : I {
  let OutOperandList = (outs);
  let InOperandList = (ins brtarget:$target);
  let AsmString = "JMP $target";
  let Pattern = [(br bb:$target)];
  let isBranch = 1; // This is a branch instruction
  let isTerminator = 1; // This instruction is part of the terminator for a basic block
  let isBarrier = 1; // Control flow cannot fall through this instruction
}

// DEX, DEY
// TODO: DEC instruction: decrement memory by one
def DE_reg : I {
  let Defs = [NF, ZF];
  let OutOperandList = (outs Index:$io);
  let InOperandList = (ins Index:$ii);
  let Constraints = "$io = $ii";
  let AsmString = "DE_reg $ii";
  let Pattern = [(set Index:$io, (sub Index:$ii, 1))];
}

// INX, INY
// TODO: INC instruction: increment memory by one
def IN_reg : I {
  let Defs = [NF, ZF];
  let OutOperandList = (outs Index:$io);
  let InOperandList = (ins Index:$ii);
  let Constraints = "$io = $ii";
  let AsmString = "IN_reg $ii";
  let Pattern = [(set Index:$io, (add Index:$ii, 1))];
}

let isMoveImm = 1, isAsCheapAsAMove = 1, isReMaterializable = 1 in {
// LDA, LDX, LDY
def LD_imm : I {
  let Defs = [NF, ZF];
  let OutOperandList = (outs PhysReg:$r);
  let InOperandList = (ins i8imm:$x);
  let AsmString = "LD_imm $r, $x";
  let Pattern = [(set PhysReg:$r, (i8 imm:$x))];
}
// Get hi byte of address (tglobaladdr, texternalsym or tblockaddress)
def LD_addr_hi : I {
  let Defs = [NF, ZF];
  let OutOperandList = (outs PhysReg:$r);
  let InOperandList = (ins iPTRimm:$addr);
  let AsmString = "LD_addr_hi $r, $addr";
  let Pattern = [(set PhysReg:$r, (M6502addrhi timm:$addr))];
}
// Get lo byte of address (tglobaladdr, texternalsym or tblockaddress)
def LD_addr_lo : I {
  let Defs = [NF, ZF];
  let OutOperandList = (outs PhysReg:$r);
  let InOperandList = (ins iPTRimm:$addr);
  let AsmString = "LD_addr_lo $r, $addr";
  let Pattern = [(set PhysReg:$r, (M6502addrlo timm:$addr))];
}
// Get hi byte of address of stack variable
// FIXME: LD_stack_addr_hi is cheap only when stack vars are allocated statically
def LD_stack_addr_hi : I {
  let Defs = [NF, ZF];
  let OutOperandList = (outs PhysReg:$r);
  let InOperandList = (ins iPTRimm:$fi);
  let AsmString = "LD_stack_addr_hi $r, [$fi]";
  let Pattern = [(set PhysReg:$r, (M6502fihi timm:$fi))];
}
// Get lo byte of address of stack variable
// FIXME: LD_stack_addr_lo is cheap only when stack vars are allocated statically
def LD_stack_addr_lo : I {
  let Defs = [NF, ZF];
  let OutOperandList = (outs PhysReg:$r);
  let InOperandList = (ins iPTRimm:$fi);
  let AsmString = "LD_stack_addr_lo $r, [$fi]";
  let Pattern = [(set PhysReg:$r, (M6502filo timm:$fi))];
}
} // isMoveImm = 1, isAsCheapAsAMove = 1, isReMaterializable = 1

def : Pat<(M6502addrhi tglobaladdr:$addr), (LD_addr_hi tglobaladdr:$addr)>;
def : Pat<(M6502addrlo tglobaladdr:$addr), (LD_addr_lo tglobaladdr:$addr)>;
def : Pat<(M6502addrhi tjumptable:$jt), (LD_addr_hi tjumptable:$jt)>;
def : Pat<(M6502addrlo tjumptable:$jt), (LD_addr_lo tjumptable:$jt)>;
// TODO: texternalsym, tblockaddress, etc.

// Load from absolute address
def LD_abs : I {
  let Defs = [NF, ZF];
  let OutOperandList = (outs PhysReg:$r);
  let InOperandList = (ins iPTRimm:$addr);
  let AsmString = "LD_abs $r, $addr";
  let Pattern = [(set PhysReg:$r, (M6502loadfrom (M6502absaddr timm:$addr)))];
  let mayLoad = 1;
  let canFoldAsLoad = 1;
}

def : Pat<(M6502loadfrom (M6502absaddr tglobaladdr:$addr)),
          (LD_abs tglobaladdr:$addr)>;
// TODO: texternalsym, etc.

// Load from absolute address with index
def LD_abs_index : I {
  let Defs = [NF, ZF];
  let OutOperandList = (outs PhysReg:$r);
  let InOperandList = (ins iPTRimm:$addr, Index:$i);
  // NOTE: X cannot be an index in LDX, and Y cannot be an index in LDY.
  let Constraints = "$r != $i";
  let AsmString = "LD_abs_index $r, $addr,$i";
  let Pattern = [(set PhysReg:$r, (M6502loadfrom (M6502absindexaddr timm:$addr, Index:$i)))];
  let mayLoad = 1;
  let canFoldAsLoad = 1;
}

def : Pat<(M6502loadfrom (M6502absindexaddr tglobaladdr:$addr, Index:$i)),
          (LD_abs_index tglobaladdr:$addr, Index:$i)>;
// TODO: texternalsym, etc.

// Load from address formed by Hi, Lo bytes
def LD_hi_lo : I {
  let Defs = [NF, ZF];
  let OutOperandList = (outs PhysReg:$r);
  let InOperandList = (ins MHReg:$hi, MLReg:$lo);
  let AsmString = "LD_hi_lo $r, ($hi, $lo)";
  let Pattern = [(set PhysReg:$r, (M6502loadfrom (M6502hiloaddr MHReg:$hi, MLReg:$lo)))];
  let mayLoad = 1;
  let canFoldAsLoad = 1;
}

// Load from address formed by Hi, Lo bytes plus variable offset
// NOTE: This instruction represents LDA with the (indirect),Y addressing mode.
// Hi and Lo regs must be in zero-page memory. Only A may be loaded this way.
def LD_hi_lo_index : I {
  let Defs = [NF, ZF];
  let OutOperandList = (outs Acc:$r);
  let InOperandList = (ins MHReg:$hi, MLReg:$lo, YReg:$i);
  let AsmString = "LD_hi_lo_index $r, ($hi, $lo),$i";
  let Pattern = [(set Acc:$r, (M6502loadfrom (M6502hiloindexaddr MHReg:$hi, MLReg:$lo, YReg:$i)))];
  let mayLoad = 1;
  let canFoldAsLoad = 1;
}

// Load from stack
def LD_stack : I {
  let Defs = [NF, ZF];
  // XXX: To support spilling of mem regs, LD_stack takes a General operand.
  // FIXME: General is wrong. Mem regs cannot be stored directly to the stack.
  // See storeRegToStackSlot in M6502InstrInfo.cpp.
  let OutOperandList = (outs General:$r);
  let InOperandList = (ins iPTRimm:$fi, iPTRimm:$offs);
  let AsmString = "LD_stack $r, [$fi]+$offs";
  let Pattern = [(set General:$r, (M6502loadfrom (M6502fiaddr tframeindex:$fi, timm:$offs)))];
  let mayLoad = 1;
  let canFoldAsLoad = 1;
}

// Load from stack plus variable offset
def LD_stack_plus_index : I {
  let Defs = [NF, ZF];
  let OutOperandList = (outs PhysReg:$r);
  let InOperandList = (ins iPTRimm:$fi, iPTRimm:$offs, Index:$i);
  // NOTE: X cannot be an index in LDX, and Y cannot be an index in LDY.
  let Constraints = "$r != $i";
  let AsmString = "LD_stack_plus_index $r, [$fi]+$offs,$i";
  let Pattern = [(set PhysReg:$r, (M6502loadfrom (M6502fiindexaddr tframeindex:$fi, timm:$offs, Index:$i)))];
  let mayLoad = 1;
  let canFoldAsLoad = 1;
}

// Store to absolute address
def ST_abs : I {
  let OutOperandList = (outs);
  let InOperandList = (ins PhysReg:$r, iPTRimm:$addr);
  let AsmString = "ST_abs $r, $addr";
  let Pattern = [(M6502storeto PhysReg:$r, (M6502absaddr timm:$addr))];
  let mayStore = 1;
}

def : Pat<(M6502storeto PhysReg:$r, (M6502absaddr tglobaladdr:$addr)),
          (ST_abs PhysReg:$r, tglobaladdr:$addr)>;
// TODO: texternalsym, etc.

// Store to absolute address with index
// NOTE: STA has indexed addressing modes. STX and STY have indexed addressing,
// but only if the address is in the zero-page. Only STA is implemented here.
def ST_abs_index : I {
  let OutOperandList = (outs);
  let InOperandList = (ins Acc:$r, iPTRimm:$addr, Index:$i);
  let AsmString = "ST_abs_index $r, $addr,$i";
  let Pattern = [(M6502storeto Acc:$r, (M6502absindexaddr timm:$addr, Index:$i))];
  let mayStore = 1;
}

def : Pat<(M6502storeto Acc:$r, (M6502absindexaddr tglobaladdr:$addr, Index:$i)),
          (ST_abs_index Acc:$r, tglobaladdr:$addr, Index:$i)>;
// TODO: texternalsym, etc.

// Store to address formed by Hi, Lo bytes
def ST_hi_lo : I {
  let OutOperandList = (outs);
  let InOperandList = (ins PhysReg:$r, MHReg:$hi, MLReg:$lo);
  let AsmString = "ST_hi_lo $r, ($hi, $lo)";
  let Pattern = [(M6502storeto PhysReg:$r, (M6502hiloaddr MHReg:$hi, MLReg:$lo))];
  let mayStore = 1;
}

// Store to address formed by Hi, Lo bytes plus variable offset
// NOTE: This instruction represents STA with the (indirect),Y addressing mode.
// Hi and Lo regs must be in zero-page memory. Only A may be stored this way.
def ST_hi_lo_index : I {
  let OutOperandList = (outs);
  let InOperandList = (ins Acc:$a, MHReg:$hi, MLReg:$lo, YReg:$i);
  let AsmString = "ST_hi_lo_index $a, ($hi, $lo),$i";
  let Pattern = [(M6502storeto Acc:$a, (M6502hiloindexaddr MHReg:$hi, MLReg:$lo, YReg:$i))];
  let mayStore = 1;
}

// Store to stack
def ST_stack : I {
  let OutOperandList = (outs);
  // XXX: To support spilling of mem regs, ST_stack takes a General operand.
  // FIXME: General is wrong. Mem regs cannot be stored directly to the stack.
  // See storeRegToStackSlot in M6502InstrInfo.cpp.
  let InOperandList = (ins General:$r, iPTRimm:$fi, iPTRimm:$offs);
  let AsmString = "ST_stack $r, [$fi]+$offs";
  let Pattern = [(M6502storeto General:$r, (M6502fiaddr tframeindex:$fi, timm:$offs))];
  let mayStore = 1;
}

// Store to stack plus variable offset
// NOTE: Only register A can be stored this way.
def ST_stack_plus_index : I {
  let OutOperandList = (outs);
  let InOperandList = (ins Acc:$a, iPTRimm:$fi, iPTRimm:$offs, Index:$i);
  let AsmString = "ST_stack_plus_index $a, [$fi]+$offs,$i";
  let Pattern = [(M6502storeto Acc:$a, (M6502fiindexaddr tframeindex:$fi, timm:$offs, Index:$i))];
  let mayStore = 1;
}

// Jump to address formed by Hi, Lo bytes
def JMP_hi_lo : I {
  let OutOperandList = (outs);
  let InOperandList = (ins MHReg:$hi, MLReg:$lo);
  let AsmString = "JMP_hi_lo ($hi, $lo)";
  let Pattern = [(M6502brind (M6502hiloaddr MHReg:$hi, MLReg:$lo))];
  let isBranch = 1; // This is a branch instruction
  let isTerminator = 1; // This instruction is part of the terminator for a basic block
  let isBarrier = 1; // Control flow cannot fall through this instruction
  let isIndirectBranch = 1; // This is an indirect branch instruction
}

def LSR_1 : I {
  let Defs = [ZF, CF];
  let OutOperandList = (outs Acc:$ao);
  let InOperandList = (ins Acc:$ai);
  let Constraints = "$ao = $ai";
  let AsmString = "LSR $ai";
  let Pattern = [(set Acc:$ao, (srl Acc:$ai, (i8 1)))];
}

// Generic call instruction
// The actual instructions generated depend on the calling convention. (TODO)
def CALL_imm : I {
  let isCall = 1; // This is a call instruction
  let OutOperandList = (outs);
  let InOperandList = (ins iPTRimm:$target);
  let AsmString = "CALL $target";
  let Pattern = [(M6502call timm:$target)];
}

// calls
def : Pat<(M6502call (i16 tglobaladdr:$dst)),
          (CALL_imm tglobaladdr:$dst)>;
def : Pat<(M6502call (i16 texternalsym:$dst)),
          (CALL_imm texternalsym:$dst)>;

// Generic return instruction
// This should emit RTS or JMP depending on the calling convention. (TODO)
def RETURN : I {
  let isReturn = 1; // This is a return instruction
  let isTerminator = 1; // This instruction is part of the terminator for a basic block
  let isBarrier = 1; // Control flow cannot fall through this instruction
  let OutOperandList = (outs);
  let InOperandList = (ins);
  let Pattern = [(M6502return)];
  let AsmString = "RETURN";
}

// TAX, TAY, TXA, TYA (may compile as memory loads/stores)
// TODO: Transfer instructions may modify flags!
// FIXME: 6502 has a limited set of register-to-register transfer instructions.
// X and Y cannot be transferred directly between themselves; neither can Mem
// registers.
def T_reg : I {
  let Defs = [NF, ZF];
  let OutOperandList = (outs General:$dst);
  let InOperandList = (ins General:$src);
  let AsmString = "T_reg $dst, $src";
  let Pattern = [];
  // NOTE: This instruction is generated by copyPhysReg.
  // Do NOT attempt to use the pattern below! If the pattern below is
  // uncommented, LLVM will mistakenly use T_reg as a "catch-all" for patterns
  // that have no other matches, leading to output like:
  //   T_reg R0, R0
  // if no other instruction that assigns the correct value to R0 can be found.
  //let Pattern = [(set General:$dst, General:$src)];
}
