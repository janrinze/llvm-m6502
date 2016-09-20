// TODO: header stuff

#include "M6502ISelLowering.h"
#include "M6502RegisterInfo.h"
#include "M6502Subtarget.h"
#include "MCTargetDesc/M6502MCTargetDesc.h"
#include "llvm/CodeGen/CallingConvLower.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/SelectionDAG.h"

using namespace llvm;

#include "M6502GenCallingConv.inc"

M6502TargetLowering::M6502TargetLowering(const TargetMachine &TM,
                                         const M6502Subtarget &Subtarget)
    : TargetLowering(TM) {

  addRegisterClass(MVT::i8, &M6502::GeneralRegClass);
  addRegisterClass(MVT::i1, &M6502::FlagRegClass);

  computeRegisterProperties(Subtarget.getRegisterInfo());

  // FIXME: should BR_CC nodes be processed in M6502ISelDAGToDAG.cpp instead of here?
  setOperationAction(ISD::BR_CC, MVT::i8, Custom);
}

const char *
M6502TargetLowering::getTargetNodeName(unsigned Opcode) const {
  switch (static_cast<M6502ISD::NodeType>(Opcode)) {
    // TODO: Use .def to automate this like WebAssembly
  case M6502ISD::FIRST_NUMBER:
    break;
  case M6502ISD::RETURN:
    return "M6502ISD::RETURN";
  case M6502ISD::CMP:
    return "M6502ISD::CMP";
  case M6502ISD::BSET:
    return "M6502ISD::BSET";
  case M6502ISD::BCLEAR:
    return "M6502ISD::BCLEAR";
  }
  return nullptr;
}

SDValue
M6502TargetLowering::LowerFormalArguments(
      SDValue Chain, CallingConv::ID CallConv, bool isVarArg,
      const SmallVectorImpl<ISD::InputArg> & Ins, const SDLoc & dl,
      SelectionDAG & DAG, SmallVectorImpl<SDValue> & InVals) const {
  // TODO
  MachineFunction &MF = DAG.getMachineFunction();

  SmallVector<CCValAssign, 16> ArgLocs;
  CCState CCInfo(CallConv, isVarArg, MF, ArgLocs, *DAG.getContext());

  CCInfo.AnalyzeFormalArguments(Ins, CC_M6502);

  for (unsigned i = 0; i < ArgLocs.size(); ++i) {
    CCValAssign &VA = ArgLocs[i];

    if (VA.isRegLoc()) {
      unsigned VReg = MF.addLiveIn(VA.getLocReg(),
                                   getRegClassFor(VA.getLocVT()));
      InVals.push_back(DAG.getCopyFromReg(Chain, dl, VReg, VA.getLocVT()));
    } else if (VA.isMemLoc()) {
      unsigned ValSize = VA.getValVT().getSizeInBits() / 8;
      int FI = MF.getFrameInfo()->CreateFixedObject(ValSize, VA.getLocMemOffset(), true);
      SDValue FIPtr = DAG.getFrameIndex(FI, getPointerTy(MF.getDataLayout()));
      SDValue Val = DAG.getLoad(VA.getLocVT(), dl, Chain, FIPtr, MachinePointerInfo());
      InVals.push_back(Val);
    } else {
      llvm_unreachable("Argument must be located in register or stack");
    }
  }

  return Chain;
}

bool
M6502TargetLowering::CanLowerReturn(CallingConv::ID CallConv,
                                    MachineFunction &MF, bool isVarArg,
                                    const SmallVectorImpl<ISD::OutputArg> &Outs,
                                    LLVMContext &Context) const {
  // TODO
  if (Outs.size() == 0)
    return true;

  return false;
}

SDValue
M6502TargetLowering::LowerReturn(SDValue Chain, CallingConv::ID CallConv,
                                 bool isVarArg,
                                 const SmallVectorImpl<ISD::OutputArg> & Outs,
                                 const SmallVectorImpl<SDValue> & OutVals,
                                 const SDLoc & dl,
                                 SelectionDAG & DAG) const {
  // TODO
  // XXX: RetOps stuff comes from WebAssemblyIselLowering and others
  MachineFunction &MF = DAG.getMachineFunction();

  SmallVector<CCValAssign, 16> RVLocs;
  CCState CCInfo(CallConv, isVarArg, MF, RVLocs, *DAG.getContext());

  CCInfo.AnalyzeReturn(Outs, RetCC_M6502);

  // FIXME: Is Glue necessary?
  SDValue Glue;
  SmallVector<SDValue, 4> RetOps(1, Chain);

  // FIXME: remove this, values are never returned in registers anymore.
  for (unsigned i = 0; i < RVLocs.size(); ++i) {
    CCValAssign &VA = RVLocs[i];
    // NOTE: If return value won't fit in registers, CanLowerReturn should
    // return false. LLVM will handle returning values on the stack.
    assert(VA.isRegLoc() && "Can only lower return into registers");

    Chain = DAG.getCopyToReg(Chain, dl, VA.getLocReg(), OutVals[i], Glue);
    Glue = Chain.getValue(1);
    RetOps.push_back(DAG.getRegister(VA.getLocReg(), VA.getLocVT()));
  }

  RetOps[0] = Chain; // Update chain.

  if (Glue) {
    RetOps.push_back(Glue);
  }

  // Generate return instruction chained to output registers
  return DAG.getNode(M6502ISD::RETURN, dl, MVT::Other, RetOps);
}

SDValue
M6502TargetLowering::LowerOperation(SDValue Op, SelectionDAG &DAG) const {
  switch (Op.getOpcode()) {
  case ISD::BR_CC: return LowerBR_CC(Op, DAG);
  default:
    llvm_unreachable("Custom lowering not implemented for operation");
    break;
  }

  return SDValue();
}

SDValue M6502TargetLowering::PerformDAGCombine(SDNode *N,
                                               DAGCombinerInfo &DCI) const {
  SelectionDAG &DAG = DCI.DAG;
  switch (N->getOpcode()) {
  default: break;
    // TODO: implement custom DAG combining
  }

  return SDValue();
}

SDValue M6502TargetLowering::LowerBR_CC(SDValue Op, SelectionDAG &DAG) const {
  SDValue Chain = Op.getOperand(0);
  ISD::CondCode CC = cast<CondCodeSDNode>(Op.getOperand(1))->get();
  SDValue LHS = Op.getOperand(2);
  SDValue RHS = Op.getOperand(3);
  SDValue Dest = Op.getOperand(4);
  SDLoc dl(Op);

  // TODO: clean up, verify correctness
  M6502ISD::NodeType NodeType1;
  unsigned int FlagReg1 = M6502::NoRegister;
  M6502ISD::NodeType NodeType2;
  unsigned int FlagReg2 = M6502::NoRegister;
  switch (CC) {
  case ISD::SETEQ:
    NodeType1 = M6502ISD::BSET;
    FlagReg1 = M6502::ZF;
    break;
  case ISD::SETNE:
    NodeType1 = M6502ISD::BCLEAR;
    FlagReg1 = M6502::ZF;
    break;
  case ISD::SETLT: // signed less-than
    NodeType1 = M6502ISD::BSET;
    FlagReg1 = M6502::NF;
    break;
  case ISD::SETLE: // signed less-than or equal
    NodeType1 = M6502ISD::BSET;
    FlagReg1 = M6502::NF;
    NodeType2 = M6502ISD::BSET;
    FlagReg2 = M6502::ZF;
    break;
  case ISD::SETGT: // signed greater-than
    NodeType1 = M6502ISD::BCLEAR;
    FlagReg1 = M6502::NF;
    break;
  case ISD::SETGE: // signed greater-than or equal
    NodeType1 = M6502ISD::BCLEAR;
    FlagReg1 = M6502::NF;
    NodeType2 = M6502ISD::BSET;
    FlagReg2 = M6502::ZF;
    break;
  case ISD::SETULT: // unsigned less-than
    NodeType1 = M6502ISD::BSET;
    FlagReg1 = M6502::CF;
    break;
  case ISD::SETULE: // unsigned less-than or equal
    NodeType1 = M6502ISD::BSET;
    FlagReg1 = M6502::CF;
    NodeType2 = M6502ISD::BSET;
    FlagReg2 = M6502::ZF;
    break;
  case ISD::SETUGT: // unsigned greater-than
    NodeType1 = M6502ISD::BCLEAR;
    FlagReg1 = M6502::CF;
    break;
  case ISD::SETUGE: // unsigned greater-than or equal
    NodeType1 = M6502ISD::BCLEAR;
    FlagReg1 = M6502::CF;
    NodeType2 = M6502ISD::BSET;
    FlagReg2 = M6502::ZF;
    break;
  default:
    llvm_unreachable("Invalid integer condition");
    break;
  }
  
  // TODO: avoid generating CMP instruction if possible, e.g. if
  // an earlier SUB instruction put the desired condition in ZFlag.
  Chain = DAG.getCopyToReg(Chain, dl, M6502::R0, LHS); // Load LHS to R0 (todo: allocate virtual register?)
  SDValue CmpGlue = DAG.getNode(M6502ISD::CMP, dl, MVT::Glue, DAG.getRegister(M6502::R0, MVT::i8), RHS);

  if (FlagReg2 != M6502::NoRegister) {
    // FIXME: glue correct?
    SDValue Branch1 = DAG.getNode(NodeType1, dl, MVT::Glue, Chain,
                                  DAG.getRegister(FlagReg1, MVT::i1), Dest, CmpGlue);
    SDValue Branch2 = DAG.getNode(NodeType2, dl, Op.getValueType(), Chain,
                                  DAG.getRegister(FlagReg2, MVT::i1), Dest, Branch1);
    return Branch2;
  } else {
    SDValue Branch1 = DAG.getNode(NodeType1, dl, Op.getValueType(), Chain,
                                  DAG.getRegister(FlagReg1, MVT::i1), Dest, CmpGlue);
    return Branch1;
  }
}
