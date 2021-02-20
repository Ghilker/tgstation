import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, LabeledList, NumberInput, ProgressBar, Section, Stack } from '../components';
import { getGasColor, getGasLabel } from '../constants';
import { formatSiBaseTenUnit, formatSiUnit } from '../format';
import { Window } from '../layouts';

export const BluespaceAtmosSender = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    on,
    gas_transfer_rate,
    price_multiplier
  } = data;
  const bluespace_network_gases = flow([
    filter(gas => gas.amount >= 0.01),
    sortBy(gas => -gas.amount),
  ])(data.bluespace_network_gases || []);
  const gasMax = Math.max(1, ...bluespace_network_gases.map(gas => gas.amount));
  return (
    <Window
     title="Bluespace Atmos Sender"
     width={500}
     height={600}>
     <Window.Content scrollable>
        <Section
          title="Controls"
          buttons={(
            <Button
              icon={data.on ? 'power-off' : 'times'}
              content={data.on ? 'On' : 'Off'}
              selected={data.on}
              onClick={() => act('power')} />
          )}>
        </Section>
        <Section title="Bluespace Network Gases">
          <LabeledList>
            {bluespace_network_gases.map(gas => (
              <LabeledList.Item
                key={gas.name}
                label={getGasLabel(gas.name)}>
                <ProgressBar
                  color={getGasColor(gas.name)}
                  value={gas.amount}
                  minValue={0}
                  maxValue={gasMax}>
                  {toFixed(gas.amount, 2) + ' moles'}
                </ProgressBar>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
