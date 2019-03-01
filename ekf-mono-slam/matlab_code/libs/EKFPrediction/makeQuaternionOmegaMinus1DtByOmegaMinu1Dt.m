function result=makeQuaternionOmegaMinus1DtByOmegaMinu1Dt(omega, delta_t)

  omegamod = norm(omega);

  result(1, 1) = dq0_by_domegaA(omega(1), omegamod, delta_t);
  result(1, 2) = dq0_by_domegaA(omega(2), omegamod, delta_t);
  result(1, 3) = dq0_by_domegaA(omega(3), omegamod, delta_t);
  result(2, 1) = dqA_by_domegaA(omega(1), omegamod, delta_t);
  result(2, 2) = dqA_by_domegaB(omega(1), omega(2), omegamod, delta_t);
  result(2, 3) = dqA_by_domegaB(omega(1), omega(3), omegamod, delta_t);
  result(3, 1) = dqA_by_domegaB(omega(2), omega(1), omegamod, delta_t);
  result(3, 2) = dqA_by_domegaA(omega(2), omegamod, delta_t);
  result(3, 3) = dqA_by_domegaB(omega(2), omega(3), omegamod, delta_t);
  result(4, 1) = dqA_by_domegaB(omega(3), omega(1), omegamod, delta_t);
  result(4, 2) = dqA_by_domegaB(omega(3), omega(2), omegamod, delta_t);
  result(4, 3) = dqA_by_domegaA(omega(3), omegamod, delta_t);
  
 return


function dq0_by_domegaARES=dq0_by_domegaA(omegaA, omega, delta_t)

  dq0_by_domegaARES=(-delta_t / 2.0) * (omegaA / omega) * sin(omega * delta_t / 2.0);
  

function dqA_by_domegaARES=dqA_by_domegaA(omegaA, omega, delta_t)
  dqA_by_domegaARES=(delta_t / 2.0) * omegaA * omegaA / (omega * omega) ...
                    * cos(omega * delta_t / 2.0) ...
                    + (1.0 / omega) * (1.0 - omegaA * omegaA / (omega * omega))...
                    * sin(omega * delta_t / 2.0);

return

function dqA_by_domegaBRES=dqA_by_domegaB(omegaA, omegaB, omega, delta_t)

  dqA_by_domegaBRES=(omegaA * omegaB / (omega * omega)) * ...
                    ( (delta_t / 2.0) * cos(omega * delta_t / 2.0) ...
                    - (1.0 / omega) * sin(omega * delta_t / 2.0) );
return    
            
