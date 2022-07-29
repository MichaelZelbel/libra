//# init --validators Alice Bob Carol Dave Eve Frank

// Testing if EVE a CASE 3 Validator gets dropped.

// ALICE is CASE 1
// BOB is CASE 1
// CAROL is CASE 1
// DAVE is CASE 1
// EVE is CASE 3
// FRANK is CASE 1

//# block --proposer Alice --time 1 --round 0

//! NewBlockEvent

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::ValidatorConfig;

    fun main(sender: signer, _: signer) {
        // Transfer enough coins to operators
        let oper_bob = ValidatorConfig::get_operator(@Bob);
        let oper_eve = ValidatorConfig::get_operator(@Eve);
        let oper_dave = ValidatorConfig::get_operator(@Dave);
        let oper_alice = ValidatorConfig::get_operator(@Alice);
        let oper_carol = ValidatorConfig::get_operator(@Carol);
        let oper_frank = ValidatorConfig::get_operator(@Frank);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Bob, oper_bob, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Eve, oper_eve, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Dave, oper_dave, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, oper_alice, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Carol, oper_carol, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Frank, oper_frank, 50009, x"", x"", &sender);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update her mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Alice) == 5, 7357180101011000);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357300101011000);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357300101011000);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Dave
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357300101011000);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Eve
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update her mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Eve) == 5, 7357180102011000);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Frank
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update her mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357180102011000);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
    // use DiemFramework::TowerState;
    use DiemFramework::Stats;
    use Std::Vector;
    // use DiemFramework::EpochBoundary;
    use DiemFramework::DiemSystem;

    fun main(vm: signer, _: signer) {
        // todo: change name to Mock epochs
        // TowerState::test_helper_set_epochs(&sender, 5);
        let voters = Vector::singleton<address>(@Alice);
        Vector::push_back<address>(&mut voters, @Bob);
        Vector::push_back<address>(&mut voters, @Carol);
        Vector::push_back<address>(&mut voters, @Dave);
        // Skip Eve.
        // Vector::push_back<address>(&mut voters, @Eve);
        Vector::push_back<address>(&mut voters, @Frank);

        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&vm, &voters);
            i = i + 1;
        };

        assert!(DiemSystem::validator_set_size() == 6, 7357008008007);
        assert!(DiemSystem::is_validator(@Alice), 7357008008008);
    }
}
//check: EXECUTED

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::DiemConfig;
    fun main() {
        // We are in a new epoch.
        assert!(DiemConfig::get_current_epoch() == 2, 7357008008009);
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 5, 7357008008010);
        assert!(DiemSystem::is_validator(@Eve) == false, 7357008008011);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
    // use DiemFramework::EpochBoundary;
    // use DiemFramework::Cases;
    use Std::Vector;
    use DiemFramework::Stats;
    
    fun main(vm: signer, _: signer) {
        let vm = &vm;
        // start a new epoch.
        // Everyone validates correctly
        // EVE cannot sign, since she is not in the validator set
        let voters = Vector::singleton<address>(@Alice);
        Vector::push_back<address>(&mut voters, @Bob);
        Vector::push_back<address>(&mut voters, @Carol);
        Vector::push_back<address>(&mut voters, @Dave);
        // Vector::push_back<address>(&mut voters, @Eve);
        Vector::push_back<address>(&mut voters, @Frank);

        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(vm, &voters);
            i = i + 1;
        };

        // // EVE did not SIGN, but did MINE, is a case 3 and will fall out of set.
        // assert!(Cases::get_case(vm, @Eve, 0, 15) == 3, 7357008008012);
        // // EpochBoundary::reconfigure(vm, 30);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update her mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357008008013);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357008008014);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357008008015);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Dave
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357008008016);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Eve
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update her mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357008008017);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Frank
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update her mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357008008018);
    }
}
//check: EXECUTED

///////////////////////////////////////////////
///// Trigger reconfiguration at 4 seconds ////
//# block --proposer Alice --time 122000000 --round 30

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::DiemConfig;
    fun main() {
        assert!(DiemConfig::get_current_epoch() == 3, 7357008008019);
        assert!(DiemSystem::validator_set_size() == 6, 7357008008020);
        assert!(DiemSystem::is_validator(@Eve), 7357008008021);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Eve
script {
    use DiemFramework::TowerState;

    fun main(_dr: signer, sender: signer) {
        // Mock some mining so Eve can send rejoin tx
        TowerState::test_helper_mock_mining(&sender, 100);
    }
}

// EVE SENDS JOIN TX
//# run --signers Eve -- 0x1::ValidatorScripts::join

///////////////////////////////////////////////
///// Trigger reconfiguration at 4 seconds ////
//# block --proposer Alice --time 183000000 --round 45

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::DiemConfig;
    fun main() {
        assert!(DiemConfig::get_current_epoch() == 4, 7357008008022);

        // Finally eve is a validator again
        assert!(DiemSystem::is_validator(@Eve), 7357008008023);
    }
}
//check: EXECUTED