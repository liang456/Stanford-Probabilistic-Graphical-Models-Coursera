function test(testc)

load PA9SampleCases


switch testc
  case 1 % EM_cluster
 [P loglikelihood ClassProb] = EM_cluster(exampleINPUT.t1a1, exampleINPUT.t1a2, exampleINPUT.t1a3, exampleINPUT.t1a4); 
 assert(P,exampleOUTPUT.t1a1,1e-3);
 assert(ClassProb,exampleOUTPUT.t1a3,1e-4);
 assert(loglikelihood,exampleOUTPUT.t1a2,1e-2); 
 disp('Success!');
  case 2 % EM_HMM
 [P loglikelihood ClassProb PairProb] = EM_HMM(exampleINPUT.t2a1, exampleINPUT.t2a2, exampleINPUT.t2a3, exampleINPUT.t2a4, exampleINPUT.t2a5, exampleINPUT.t2a6);
 assert(P,exampleOUTPUT.t2a1,1e-3);
 assert(ClassProb,exampleOUTPUT.t2a3,1e-5);
 assert(PairProb,exampleOUTPUT.t2a4,1e-5); 
 assert(loglikelihood,exampleOUTPUT.t2a2,1e-3); 
 disp('Success!');
 case 3 % EM_HMM - first iteration
 [P loglikelihood ClassProb PairProb] = EM_HMM(exampleINPUT.t2a1, exampleINPUT.t2a2, exampleINPUT.t2a3, exampleINPUT.t2a4, exampleINPUT.t2a5, 1);
 assert(P,exampleOUTPUT.t2a1b,1e-3);
 assert(ClassProb,exampleOUTPUT.t2a3b,1e-5);
 assert(PairProb,exampleOUTPUT.t2a4b,1e-5); 
 assert(loglikelihood,exampleOUTPUT.t2a2b,1e-3); 
 disp('Success!');
end