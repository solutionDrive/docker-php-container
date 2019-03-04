control 'bash' do
    impact 1.0
    title 'verifies bash exists'
    desc '
        In order to work with this container
        bash should be usable
    '

    describe command('bash') do
        it { should exist }
    end
end
